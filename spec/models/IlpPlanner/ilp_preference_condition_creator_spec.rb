require 'rails_helper'

load(File.join(Rails.root, 'lib', 'ilp_planner.rb'))

module IlpPlanner
  RSpec.describe PreferenceConditionCreator, type: :model do

    before(:all) do
      puts 'Be sure you have loaded correct test data .... (TODO make this automatic)'
    end

    it 'Should correctly build AND conditions' do
      event = Event.first

      condition_creator = PreferenceConditionCreator.new(event)

      test_setups = [
          {participant_count: 2, row_values: [1, 1, 0, 0]},
          {participant_count: 3, row_values: [1, 1, 1, 0]}
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

      condition_creator = PreferenceConditionCreator.new(event)

      test_setups = [
          {participant_count: 2, row_values: [1, 1, 0, 0], right_side: 1},
          {participant_count: 3, row_values: [1, 1, 1, 0], right_side: 1}
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

    it 'Should correctly build (..||..) => conditions' do
      event = Event.first

      condition_creator = PreferenceConditionCreator.new(event)

      test_data = [
          {participant_count: 2, row_values: [1, -1, 0, 0]},
          {participant_count: 3, row_values: [1, 1, -2, 0]},
          {participant_count: 4, row_values: [1, 1, 1, -3]}

      ]

      test_data.each do |data|
        participant_ids = event.participants
                              .order(:id => :asc)
                              .limit(data[:participant_count])
                              .map { |participant| participant.id }

        condition = condition_creator.create_multiple_or_implicate_condition(participant_ids.take(participant_ids.length-1), participant_ids.slice(-1))

        expect(condition.row_values).to eq data[:row_values]
        expect(condition.equality_operator).to eq EqualityTypes::LESS_OR_EQUAL_THAN
        expect(condition.right_side_value).to eq 0
      end

    end

    it 'Should correctly build (..&&..) => conditions' do
      event = Event.first

      condition_creator = PreferenceConditionCreator.new(event)

      test_data = [
          {participant_count: 3, row_values: [1, 1, -1, 0], right_side: 1},
          {participant_count: 4, row_values: [1, 1, 1, -1], right_side: 2}

      ]

      test_data.each do |data|
        participant_ids = event.participants
                              .order(:id => :asc)
                              .limit(data[:participant_count])
                              .map { |participant| participant.id }

        condition = condition_creator.create_multiple_and_implicate_condition(participant_ids.take(participant_ids.length-1), participant_ids.slice(-1))

        expect(condition.row_values).to eq data[:row_values]
        expect(condition.equality_operator).to eq EqualityTypes::LESS_OR_EQUAL_THAN
        expect(condition.right_side_value).to eq data[:right_side]
      end
    end

    it 'Should correctly build (!..&&..!) => conditions' do
      event = Event.first

      condition_creator = PreferenceConditionCreator.new(event)

      test_data = [
          {participant_count: 3, row_values: [1, 1, -1, 0]},
          {participant_count: 4, row_values: [1, 1, 1, -1]}

      ]

      test_data.each do |data|
        participant_ids = event.participants
                              .order(:id => :asc)
                              .limit(data[:participant_count])
                              .map { |participant| participant.id }

        condition = condition_creator.create_multiple_not_and_implicate_condition(participant_ids.take(participant_ids.length-1), participant_ids.slice(-1))

        expect(condition.row_values).to eq data[:row_values]
        expect(condition.equality_operator).to eq EqualityTypes::GREATER_OR_EQUAL_THAN
        expect(condition.right_side_value).to eq 0
      end

    end

  end
end
