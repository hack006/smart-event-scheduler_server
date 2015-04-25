require 'ilp_planner/index_range'
require 'ilp_planner/d2matrix_information'

module IlpPlanner
  class PlannerService
    # Get the dimensions of A matrix used to calculate best date match using ILP
    #
    # @param [Event] event
    # @return [D2MatrixInformation]
    def self.calc_matrix_information_for_event(event)
      slot_index_ranges = {}

      event_slot_count = event.slots.count
      event_participant_count = event.participants.count
      event_condition_count = PreferenceCondition.where('participant_id IN (?)', event.participants.map { |p| p.id}).count

      column_size = event_slot_count * event_participant_count
      row_size = event_slot_count * (1 + event_condition_count)

      event_slot_ids_asc = event.slots
                               .select('id')
                               .order(id: :asc)
                               .map { |slot| slot.id}

      event.slots.each_with_index do |slot, index|
        event_slot_start = event_slot_count * index
        event_slot_stop = event_slot_start + event_slot_count - 1

        slot_index_ranges[slot.id] = IndexRange.new( event_slot_start, event_slot_stop )
      end

      D2MatrixInformation.new(row_size, column_size, slot_index_ranges, event_slot_ids_asc)
    end

    private
      def self.calculate_column_size(event)

      end

      def self.calculate_row_size

      end
  end
end