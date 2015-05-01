require 'rails_helper'

load(File.join(Rails.root, 'lib', 'ilp_planner.rb'))

module IlpPlanner
  RSpec.describe IlpPreferenceConditionCreator, type: :model do

    before(:all) do
      puts 'Be sure you have loaded correct test data .... (TODO make this automatic)'
    end

    it 'Should correctly build AND conditions' do
      event = Event.first

      condition_creator = IlpPreferenceConditionCreator.new(event)

      test_setups = [
          {row_values: [1, 1, 0, 0], participant_count: 2},
          {row_values: [1, 1, 1, 0], participant_count: 3}
      ]

      test_setups.each do |setup|
        participant_ids = event.participants
                              .order(:id => :asc)
                              .limit(setup[:participant_count])
                              .map { |participant| participant.id }

        condition = condition_creator.create_and_condition(participant_ids)

        expect(condition.row_values).to eq setup[:row_values]
        expect(condition.right_side_value).to eq setup[:participant_count]
      end
    end

    it 'Should correctly build OR conditions' do
      event = Event.first

      condition_creator = IlpPreferenceConditionCreator.new(event)

      test_setups = [
          {row_values: [1, 1, 0, 0], participant_count: 2, right_side: 1},
          {row_values: [1, 1, 1, 0], participant_count: 3, right_side: 1}
      ]

      test_setups.each do |setup|
        participant_ids = event.participants
                              .order(:id => :asc)
                              .limit(setup[:participant_count])
                              .map { |participant| participant.id }

        condition = condition_creator.create_or_condition(participant_ids)

        expect(condition.row_values).to eq setup[:row_values]
        expect(condition.right_side_value).to eq setup[:right_side]
      end
    end

  end
end
