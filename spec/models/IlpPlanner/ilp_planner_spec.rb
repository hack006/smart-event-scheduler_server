require 'rails_helper'

load File.join(Rails.root, 'lib', 'ilp_planner.rb')

module IlpPlanner
  RSpec.describe PlannerService, type: :model do
    before(:all) do
      # Rake::Task['ses:test_data'].invoke
      puts 'Be sure you have loaded correct test data .... (TODO make this automatic)'
    end

    it 'should correctly create ILP problem' do
      event = Event.first

      results = IlpPlanner::Planner.plan(event.id).to_s

      puts results

      expect(results).to be_a_kind_of String
      expect(results.length).to be > 0
    end
  end

end