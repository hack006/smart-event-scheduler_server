require 'rails_helper'
require 'rake'

load File.join(Rails.root, 'lib', 'tasks', 'ses_test.rake')
load File.join(Rails.root, 'lib', 'ilp_planner', 'planner_service.rb')

module IlpPlanner
  RSpec.describe PlannerService, type: :model do
    before(:all) do
      # Rake::Task['ses:test_data'].invoke
      puts 'Be sure you have loaded correct test data .... (TODO make this automatic)'
    end

    it 'should give correct results for calc_matrix_information_for_slot(slot_id)' do

      event = Event.first
      slot_1 = event.slots.first
      expect(event.id).to eq 1
      expect(slot_1.id).to eq 1

      matrix = IlpPlanner::PlannerService.calc_matrix_information_for_event(event)

      expect(matrix.m).to equal(3) # 3 conditions
      expect(matrix.n).to equal(4) # 4 participants
    end

    it 'should give correct results for calculate_participant_wish_ranking()' do

      event = Event.first
      assert_equal 1, event.id
      wish_rankings = IlpPlanner::PlannerService.calc_participant_wish_ratings(event)

      expected_values = {1 => 13, 2 => 6, 3 => 5, 4 => 15}

      expected_values.each do |participant_id, wish_ranking|
        expect(wish_rankings[participant_id]).to equal(wish_ranking)
      end
    end
  end

end

