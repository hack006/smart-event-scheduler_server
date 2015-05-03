module IlpPlanner
  # Entry point to the planner API
  #
  # @author Ondřej Janata (https://www.linkedin.com/pub/ondřej-janata/9b/a2b/830)
  # @version 1.0 alpha
  class PlannerOperator

    # @param [Integer] event_id
    def initialize(event_id)
      @event = Event.find(event_id)
    end

    # @return [EventPlanningResult]
    def find_best_slot
      slot_result = nil
      total_calculation_time_ms = 0

      current_best_solution_criterial_value = - Integer::GIGABYTE
      sorted_slots_by_maximum_ranking_desc = sort_slots_by_maximum_ranking_desc

      sorted_slots_by_maximum_ranking_desc.each_with_index do |slot_ranking, index|
        if slot_ranking.maximum_ranking <= current_best_solution_criterial_value
          puts "Better solution can not be found - terminating after #{index} out of #{sorted_slots_by_maximum_ranking_desc.length} iterations"
          break
        end

        slot = slot_ranking.slot
        current_result = IlpPlanner::SlotPlanner.plan_slot(slot)
        total_calculation_time_ms += current_result.calculation_time_ms

        if current_result.criterial_value > current_best_solution_criterial_value
          slot_result = current_result
          current_best_solution_criterial_value = current_result.criterial_value
        end
      end

      if slot_result.nil?
        return IlpPlanner::EventPlanningResult.no_result(@event, total_calculation_time_ms)
      else
        return IlpPlanner::EventPlanningResult.new(slot_result.slot, slot_result.criterial_value, slot_result.variable_values, slot_result.calculation_time_ms, @event, total_calculation_time_ms)
      end
    end

    private

    # @return [Array<Slot>]
    def sort_slots_by_maximum_ranking_desc
      participant_id_wish_ratings = IlpPlanner::PlannerService.calc_participant_wish_ratings(@event.id)
      ranked_slots = []

      @event.slots.each do |slot|
        slot_maximum_ranking = 0

        slot.availabilities.where(status: AvailabilityStatuses::AVAILABLE).each do |availability|
          slot_maximum_ranking += participant_id_wish_ratings[availability.participant.id]
        end

        ranked_slots << IlpPlanner::SlotRanking.new(slot, slot_maximum_ranking)
      end

      ranked_slots.sort.reverse
    end

  end

  class SlotRanking
    attr_accessor :slot, :maximum_ranking

    def initialize(slot, maximum_ranking)
      @slot = slot
      @maximum_ranking = maximum_ranking
    end

    # @param [SlotRanking] other
    def <=>(other)
      if self.maximum_ranking > other.maximum_ranking
        1
      elsif self.maximum_ranking < other.maximum_ranking
        -1
      else
        0
      end
    end
  end

  # @attr_accessor :slot
  # @attr_accessor :criterial_value
  # @attr_accessor :variable_values
  # @attr_accessor :calculation_time_ms
  class SlotPlanningResult
    attr_reader :slot, :criterial_value, :variable_values, :calculation_time_ms

    # @param [Slot] slot
    # @param [Numeric] criterial_value
    # @param [Array<Numeric>] variable_values
    # @param [Integer] calculation_time_ms time in ms elapsed when calculating solution
    def initialize(slot, criterial_value, variable_values, calculation_time_ms)
      @slot = slot
      @criterial_value = criterial_value
      @variable_values = variable_values
      @calculation_time_ms = calculation_time_ms
    end

    def self.no_result
      SlotPlanningResult.new(nil, nil, nil, nil)
    end

    def result_found?
      !@criterial_value.nil?
    end
  end

  # @attr_accessor :event
  # @attr_accessor :event_calculation_time_ms
  class EventPlanningResult < SlotPlanningResult
    attr_reader :event, :event_calculation_time_ms

    # @param [Slot] slot
    # @param [Numeric] criterial_value
    # @param [Array<Numeric>] variable_values
    # @param [Integer] calculation_time_ms time in ms elapsed when calculating solution
    # @param [Event] event
    # @param [Integer] event_calculation_time_ms
    def initialize(slot, criterial_value, variable_values, calculation_time_ms, event, event_calculation_time_ms)
      super(slot, criterial_value, variable_values, calculation_time_ms)

      @event = event
      @event_calculation_time_ms = event_calculation_time_ms
    end

    def self.no_result(event, event_calculation_time)
      EventPlanningResult.new(nil, nil, nil, nil, event, event_calculation_time)
    end
  end
end