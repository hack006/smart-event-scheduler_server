load File.join(Rails.root, 'lib', 'ilp_planner.rb')

namespace :ses do
  task :benchmark => :environment do
    raise 'Error, can be only run under TEST environment' if Rails.env != 'test'

    repetitions = 5

    benchmark_setups = [
        {participant_count: 4, times_count: 6},
        {participant_count: 8, times_count: 6},
        {participant_count: 12, times_count: 6},
        {participant_count: 15, times_count: 6},
        {participant_count: 18, times_count: 6},
        {participant_count: 20, times_count: 6},
        {participant_count: 22, times_count: 6},
        {participant_count: 24, times_count: 6},
        {participant_count: 25, times_count: 6}
    ]
    benchmark_results = Array.new(benchmark_setups.length)

    benchmark_setups.each_with_index do |b, b_index|
      puts "Starting benchmark trial ... \n"
      results = []
      benchmark_results[b_index] = results

      for i in 1..repetitions
        Rake::Task['ses:generate_test_data'].invoke(b[:participant_count], b[:times_count])
        Rake::Task['ses:generate_test_data'].reenable

        event = Event.first

        planner_operator = IlpPlanner::PlannerOperator.new(event.id)
        planning_result = planner_operator.find_best_slot

        # slot, criterial_value, variable_values, calculation_time_ms, event, event_calculation_time_ms
        puts "Scheduled in: #{planning_result.event_calculation_time_ms} ms\n"
        results << planning_result
      end
    end

    puts "=====BENCHMARK RESULTS=====\n"

    benchmark_results.each do |benchmark_result|
      puts "AVG scheduling time: #{benchmark_result.inject(0){|sum, r| sum + r.event_calculation_time_ms} / repetitions}\n"
    end

  end
end