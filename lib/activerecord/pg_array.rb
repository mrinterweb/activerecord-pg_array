require "activerecord/pg_array/version"

module ActiveRecord
  module PGArray

    def self.included(base)
      base.class_eval do

        def self.config_array_serializer(hash)
          @@id_attr_map = hash
        end

        self.column_types.to_a.select { |c| c[1].instance_variable_get('@array') }.map(&:first).each do |attr_name|
          ids_regex = /_ids$/
          friendly_attr = attr_name.sub(ids_regex,'')
          segs = friendly_attr.split('_')
          segs[-1] = segs[-1].singularize
          friendly_attr_singular = segs.join('_')
          segs[-1] = segs[-1].pluralize
          friendly_attr_plural = segs.join('_')

          obj_convert = ->(obj) do
            custom_serializer = @@id_attr_map[attr_name.to_sym][obj.class.name.to_sym] rescue nil

            if custom_serializer
              obj = obj.send(custom_serializer)
            elsif attr_name =~ ids_regex && obj.kind_of?(ActiveRecord::Base) and
                  self.column_types[attr_name].type == :integer
              obj = obj.id
            end
            obj
          end

          atr = ->(slf) do
            slf.send attr_name.to_sym
          end

          atr_will_change = ->(slf) do
            slf.send(:"#{attr_name}_will_change!")
          end

          define_method :"add_#{friendly_attr_singular}" do |obj|
            obj = obj_convert[obj]
            unless atr[self].include?(obj)
              atr[self].push(obj)
              atr_will_change[self]
            end
          end

          define_method :"add_#{friendly_attr_singular}!" do |obj|
            obj = obj_convert[obj]
            atr_will_change[self] # seems strange that calling this is needed

            # There are two external issues that block atomic updates to one attribute.
            # 1. ActiveRecord update_attribute actually updates all attributes that are dirty! This surprised me.
            # 2. update_column doesn't work on pg arrays for rails < 4.0.4 (which is not yet released)
            #    https://github.com/rails/rails/issues/12261
            atr[self].push(obj).uniq!
            self.update_attribute attr_name.to_sym, atr[self]
          end

          define_method :"add_#{friendly_attr_plural}" do |*objs|
            objs.each do |obj|
              if obj.kind_of? Array
                self.send :"add_#{friendly_attr_plural}", *obj
              else
                self.send :"add_#{friendly_attr_singular}", obj
              end
            end
          end

          define_method :"add_#{friendly_attr_plural}!" do |*objs|
            self.send :"add_#{friendly_attr_plural}", *objs
            self.save!
          end

          define_method :"remove_#{friendly_attr_singular}" do |obj|
            obj = obj_convert.call(obj)
            if atr[self].include?(obj)
              atr[self].delete(obj)
              atr_will_change[self]
            end
          end

          define_method :"remove_#{friendly_attr_singular}!" do |obj|
            self.send :"remove_#{friendly_attr_singular}", obj
            self.save!
          end

          define_method :"remove_#{friendly_attr_plural}" do |*objs|
            objs.each do |obj|
              if obj.kind_of? Array
                self.send :"remove_#{friendly_attr_plural}", *obj
              else
                self.send :"remove_#{friendly_attr_singular}", obj
              end
            end
          end

          define_method :"remove_#{friendly_attr_plural}!" do |*objs|
            self.send :"remove_#{friendly_attr_plural}", *objs
            self.save!
          end

          # define basic relational lookup methods
          # example:
          #   Given wolf_ids is the attribute
          #   Then it will try to define method wolves that retrieves wolf objects
          if attr_name =~ ids_regex
            if defined?(friendly_attr_singular.camelize.to_sym) and
               self.column_types[attr_name].type == :integer
              begin
                klass = friendly_attr_singular.camelize.constantize

                # it might be better to define a scope instead
                define_method friendly_attr_plural.to_sym do
                  # passing an empty array to a SQL `IN` clause throws a PG::SyntaxError;
                  # check to see if there are any items in the array and
                  # send back any empty array if empty...
                  self.send(attr_name).empty? ? [] : klass.where(id: [atr[self]])
                end
              rescue NameError
              end
            end
          end

        end
      end # base.class_eval
    end # self.include

  end
end
