require 'spec_helper'
require 'support/active_record'
require 'pry'

class WolfTracker < ActiveRecord::Base
  include ActiveRecord::PGArray
end

describe WolfTracker do
  let(:wolf_tracker)  { WolfTracker.create(name: 'Wolfram') }
  let(:wolfy) { WolfTracker.create(name: 'Wolfy') }
  let(:son_of_wolfy) { WolfTracker.create(name: 'Son of Wolfy') }
  let(:wolfia) { WolfTracker.create(name: 'Wolfia') }

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
    it { should respond_to(:remove_pack_name) }
    it { should respond_to(:remove_pack_name!) }
  end

  context 'persistence' do

    context "with ActiveRecord object" do
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
        wolf_tracker.reload
        expect(wolf_tracker.name).to eq 'Wolfram'
      end
    end # with ActiveRecord object

    it 'should have more specs' do
      pending 'you\'re not done writing specs'
    end

  end
end
