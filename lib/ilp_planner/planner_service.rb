module IlpPlanner
  class PlannerService
    # Get the dimensions of A matrix used to calculate best date match using ILP
    #
    # @param [Slot] slot
    # @return [D2MatrixInformation]
    def self.calc_matrix_information_for_event(slot)
      event = slot.event
      free_row_start_index = 0

      event_participant_count = event.participants.count
      event_participant_ids = self.get_participant_ids(event.id)
      event_condition_count = PreferenceCondition.where('participant_id IN (?)', event_participant_ids).count

      free_row_start_index += event_condition_count

      inactive_participants_count = slot.availabilities.where(status: AvailabilityStatuses::NOT_AVAILABLE).count
      inactive_participants_range = IndexRange.new(free_row_start_index, free_row_start_index + inactive_participants_count - 1)
      free_row_start_index += inactive_participants_count

      participant_count_requirements_count = 0
      participant_count_requirements_count += 1 if slot.activity_detail.minimum_count.present?
      participant_count_requirements_count += 1 if slot.activity_detail.maximum_count.present?
      count_requirements_range = IndexRange.new(free_row_start_index, free_row_start_index + participant_count_requirements_count - 1)
      free_row_start_index += participant_count_requirements_count

      column_size = event_participant_count
      row_size = event_condition_count + inactive_participants_count + participant_count_requirements_count

      D2MatrixInformation.new(row_size, column_size, inactive_participants_range, count_requirements_range)
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

    def self.get_event_participant_id(event_id, participant_id)
      self.get_participant_ids(event_id).index(participant_id)
    end

  end
end