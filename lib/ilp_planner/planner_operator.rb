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
      result = nil

      current_best_solution_criterial_value = - Integer::GIGABYTE
      sorted_slots_by_maximum_ranking_desc = sort_slots_by_maximum_ranking_desc

      sorted_slots_by_maximum_ranking_desc.each_with_index do |slot_ranking, index|
        if slot_ranking.maximum_ranking <= current_best_solution_criterial_value
          puts "Better solution can not be found - terminating after #{index} out of #{sorted_slots_by_maximum_ranking_desc.length} iterations"
          break
        end

        slot = slot_ranking.slot
        result = IlpPlanner::SlotPlanner.plan_slot(slot)
        current_best_solution_criterial_value = result.criterial_value
      end

      return IlpPlanner::EventPlanningResult.no_result if result.nil?
      result
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
  class EventPlanningResult
    attr_reader :slot, :criterial_value, :variable_values

    # @param [Slot] slot
    # @param [Numeric] criterial_value
    # @param [Array<Numeric>] variable_values
    def initialize(slot, criterial_value, variable_values)
      @slot = slot
      @criterial_value = criterial_value
      @variable_values = variable_values
    end

    def self.no_result
      EventPlanningResult.new(nil, nil, nil)
    end

    def result_found?
      !@criterial_value.nil?
    end
  end
end