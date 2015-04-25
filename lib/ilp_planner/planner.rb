require 'planner_service'

module IlpPlanner
  class Planner
    @event
    @a_matrix
    @matrix_size

    def plan (event_id)

    end

    private
      def setup_new_calculation_for(event_id)
        @event = Event.find(event_id)

        @matrix_size = IlpPlanner::PlannerService.calc_matrix_information_for_event(@event)
      end
  end
end