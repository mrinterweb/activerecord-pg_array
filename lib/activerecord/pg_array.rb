require "activerecord/pg_array/version"

module ActiveRecord
  module PGArray

    def self.included(base)
      base.class_eval do
        self.column_types.to_a.select { |c| c[1].instance_variable_get('@array') }.map(&:first).each do |array_column_name|
          ids_regex = /_ids$/
          friendly_attr = array_column_name.sub(ids_regex,'')
          segs = friendly_attr.split('_')
          segs[-1] = segs[-1].singularize
          friendly_attr_singular = segs.join('_')
          segs[-1] = segs[-1].pluralize
          friendly_attr_plural = segs.join('_')

          obj_convert = ->(obj) do
            if array_column_name =~ ids_regex && obj.kind_of?(ActiveRecord::Base)
              # todo - check to make sure that array_column_name is an attribute
              # todo - also, I don't know if array_column name is so hot. Maybe just attr_name
              obj = obj.id
            end
            obj
          end
          atr = ->(slf) do
            slf.send array_column_name.to_sym
          end
          atr_will_change = ->(slf) do
            slf.send(:"#{array_column_name}_will_change!")
          end

          define_method :"add_#{friendly_attr_singular}" do |obj|
            obj = obj_convert[obj]
            unless atr[self].include?(obj)
              atr[self].push(obj)
              atr_will_change[self]
            end
          end

          define_method :"add_#{friendly_attr_singular}!" do |obj|
            self.send :"add_#{friendly_attr_singular}", obj
            self.save!
          end

          define_method :"add_#{friendly_attr_plural}" do |objs|
            objs.each do |obj|
              self.send :"add_#{friendly_attr_singular}", obj
            end
          end

          define_method :"remove_#{friendly_attr_singular}" do |obj|
            obj = obj_convert.call(obj)
            if atr[self].include?(obj)
              atr[self].remove(obj)
              atr_will_change[self]
            end
          end

          define_method :"remove_#{friendly_attr_singular}!" do |obj|
            self.send :"remove_#{friendly_attr_singular}", obj
            self.save!
          end

        end
      end # base.class_eval
    end # self.include

  end
end
