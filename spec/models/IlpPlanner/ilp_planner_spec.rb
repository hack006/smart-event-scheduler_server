require 'rails_helper'

load File.join(Rails.root, 'lib', 'ilp_planner', 'planner.rb')

module IlpPlanner
  RSpec.describe PlannerService, type: :model do
    before(:all) do
      # Rake::Task['ses:test_data'].invoke
      puts 'Be sure you have loaded correct test data .... (TODO make this automatic)'
    end

    it 'should correctly create ILP problem' do
      event = Event.first

      puts IlpPlanner::Planner.plan(event.id).to_s
    end
  end

end