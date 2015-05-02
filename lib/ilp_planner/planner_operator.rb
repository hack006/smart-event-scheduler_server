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

    def find_best_slot
      results = []

      @event.slots.each_with_index do |slot, index|
        # TODO store results and get the best one
        # TODO reduce calculation of all variants if any better could not be found

        results << IlpPlanner::SlotPlanner.plan_slot(slot)
      end

      results
    end

    private


  end
end