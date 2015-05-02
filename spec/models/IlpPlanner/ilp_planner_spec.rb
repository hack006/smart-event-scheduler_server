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

      event_planner_operator = IlpPlanner::PlannerOperator.new(event.id)
      result =  event_planner_operator.find_best_slot

      puts "Criterial value: #{result.criterial_value}\n"
      puts "Variable values: #{result.variable_values}\n"

      expect(result.criterial_value).to be_a_kind_of Numeric
      expect(result.criterial_value).to eq 33
    end
  end

end