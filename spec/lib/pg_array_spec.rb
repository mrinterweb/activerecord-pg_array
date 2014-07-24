require 'spec_helper'
require 'active_record'

class Wolf < ActiveRecord::Base
  # config_array_serializer names: :name
end

class Chicken < ActiveRecord::Base
end

require 'support/active_record'
require 'pry'

class WolfTracker < ActiveRecord::Base
  include ActiveRecord::PGArray
  config_array_serializer pack_names: {:Wolf => :name}
end

describe WolfTracker do
  let(:wolf_tracker)  { WolfTracker.create(name: 'Wolfram') }
  let(:wolfy) { Wolf.create(name: 'Wolfy') }
  let(:son_of_wolfy) { Wolf.create(name: 'Son of Wolfy') }
  let(:wolfia) { Wolf.create(name: 'Wolfia') }

  context 'base state' do
    it "should have empty wolf_ids" do
      expect(wolf_tracker.wolf_ids).to be_empty
    end

    it "should have empty pack_names" do
      expect(wolf_tracker.pack_names).to be_empty
    end
  end

  context 'method names' do
    subject { WolfTracker.new }

    it { should respond_to(:add_wolf) }
    it { should respond_to(:add_wolf!) }
    it { should respond_to(:add_wolves) }
    it { should respond_to(:remove_wolf) }
    it { should respond_to(:remove_wolf!) }

    it { should respond_to(:add_pack_name) }
    it { should respond_to(:add_pack_name!) }
    it { should respond_to(:add_pack_names) }
    it { should respond_to(:add_pack_names!) }
    it { should respond_to(:remove_pack_name) }
    it { should respond_to(:remove_pack_name!) }
    it { should respond_to(:remove_pack_names) }
    it { should respond_to(:remove_pack_names!) }
  end

  context 'persistence' do

    context "add_<attr_name>" do
      it "should contain the id in the <attr>_ids attribute" do
        wolf_tracker.add_wolf(wolfy)
        expect(wolf_tracker.wolf_ids).to eq [wolfy.id]
      end

      it "should be able to add a non integer attribute type to an array" do
        wolf_tracker.add_pack_name(wolfy)
        expect(wolf_tracker.pack_names).to eq [wolfy.name]
      end

      it "should add_<attr>" do
        wolf_tracker.add_wolf(wolfy)
        wolf_tracker.save!
        wolf_tracker.reload
        expect(wolf_tracker.wolf_ids).to eq [wolfy.id]
      end

      it "should add_<attr>! " do
        wolf_tracker.add_wolf!(wolfy)
        wolf_tracker.reload
        expect(wolf_tracker.wolf_ids).to eq [wolfy.id]
      end

      it "should not update other changed attributes if atomic" do
        wolf_tracker.name = 'Big Bad Wolf'
        wolf_tracker.add_wolf!(wolfy)
        pending "see note where add_<attr_name>! is defined. blocked by external issues"
        wolf_tracker.reload
        expect(wolf_tracker.name).to eq 'Wolfram'
      end

      it "should add multiple add_<atts>! with multiple arguments" do
        wolf_tracker.add_pack_names!('red fang', 'midnight howlers')
        wolf_tracker.reload
        wolf_tracker.pack_names.length.should be 2
      end

      it "should add multiple add_<atts>! with an array argument" do
        wolf_tracker.add_pack_names!(['red fang', 'midnight howlers'])
        wolf_tracker.reload
        wolf_tracker.pack_names.length.should be 2
      end

      it "should add multiple add_<atts>! with an array argument of class instances" do
        wolf_tracker.add_pack_names!([wolfy, son_of_wolfy])
        wolf_tracker.reload
        expect(wolf_tracker.pack_names).to match_array [wolfy.name, son_of_wolfy.name]
      end

      it "should add with regular integer value" do
        wolf_tracker.add_wolf(1)
        wolf_tracker.save!
        wolf_tracker.reload
        expect(wolf_tracker.wolf_ids).to eq [1]
      end

      it "should add with regular string value" do
        wolf_tracker.add_pack_name('of one')
        wolf_tracker.save!
        expect(wolf_tracker.reload.pack_names).to eq ['of one']
      end

    end # with ActiveRecord object

    context "remove" do
      before do
        wolf_tracker.add_wolf!(wolfy)
        wolf_tracker.reload
        expect(wolf_tracker.wolf_ids).to eq [wolfy.id]
      end

      it "should remove_<attr>" do
        wolf_tracker.remove_wolf(wolfy)
        wolf_tracker.save!
        expect(wolf_tracker.reload.wolf_ids).to be_empty
      end

      it "should remove_<attr>!" do
        wolf_tracker.remove_wolf!(wolfy.id)
        expect(wolf_tracker.reload.wolf_ids).to be_empty
      end

      context "multiple" do
        before  do
          wolf_tracker.add_wolf!(son_of_wolfy)
          expect(wolf_tracker.wolf_ids.length).to eq 2
        end

        it "should be called with an array argument" do
          wolf_tracker.remove_wolves([wolfy, son_of_wolfy])
          expect(wolf_tracker.wolf_ids.length).to eq 0
          expect(wolf_tracker.reload.wolf_ids.length).to eq 2
        end

        it "should be called with multiple arguments" do
          wolf_tracker.remove_wolves(wolfy, son_of_wolfy)
          expect(wolf_tracker.wolf_ids.length).to eq 0
          expect(wolf_tracker.reload.wolf_ids.length).to eq 2
        end

        it "should remove multiple and persist with !" do
          wolf_tracker.remove_wolves!(wolfy, son_of_wolfy)
          expect(wolf_tracker.reload.wolf_ids.length).to eq 0
        end

      end
    end # remove

    it 'should have more specs' do
      pending 'you\'re not done writing specs'
    end

  end # persistence

  describe "finder methods" do
    before do
      wolf_tracker.add_wolves(wolfy, son_of_wolfy) 
      wolf_tracker.save!
    end

    it { should respond_to(:wolves) }
    it { should_not respond_to(:chickens) }

    it "should have a wolves finder method and return a wolf" do
      expect(wolf_tracker.wolves).to eq [wolfy, son_of_wolfy]
    end

  end # scopes
end
