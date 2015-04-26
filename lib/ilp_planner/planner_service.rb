require 'ilp_planner/index_range'
require 'ilp_planner/d2matrix_information'

module IlpPlanner
  class PlannerService
    # Get the dimensions of A matrix used to calculate best date match using ILP
    #
    # @param [Event] event
    # @return [D2MatrixInformation]
    def self.calc_matrix_information_for_slot(slot)
      slot_index_ranges = {}
      event = slot.event

      event_participant_count = event.participants.count
      event_participant_ids = self.get_participant_ids(event.id)
      event_condition_count = PreferenceCondition.where('participant_id IN (?)', event_participant_ids).count

      column_size = event_participant_count
      row_size = event_condition_count

      event_slot_ids_asc = event.slots
                               .select('id')
                               .order(id: :asc)
                               .map { |slot| slot.id}

      D2MatrixInformation.new(row_size, column_size, event_slot_ids_asc)
    end

    # Calculates participant wish ratings (how they are valuable for others to participate)
    #
    # Value is based
    # @TODO calculation is based on all preference_priorizations, maybe some better heuristic could be found
    #
    # @param [Integer] event_id
    # @return [Hash] wish ratings for each participant, [Integer] key - participant_id, [Integer] value - wish ranking
    def self.calc_participant_wish_ratings(event_id)
      participant_wish_rankings = {}

      self.get_participant_ids(event_id).each do |participant_id|
        participant_wish_rankings[participant_id] = 0

        PreferencePrioritization
            .where(:for_participant_id => participant_id)
            .each{ |preference_priority| participant_wish_rankings[participant_id] += preference_priority.multiplier }
      end

      return participant_wish_rankings
    end

    def self.get_participant_ids(event_id)
      participant_ids = []
      Event.find(event_id).participants
          .select('id')
          .each { |participant| participant_ids << participant.id }

      return participant_ids
    end

  end
end