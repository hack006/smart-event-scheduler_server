module IlpPlanner
  class IlpPreferenceConditionCreator

    def initialize(event)
      @event = event
      @matrix_information = IlpPlanner::PlannerService.calc_matrix_information_for_event(event)
    end

    # Creates n-ary AND condition
    #
    # Modeled by: x(1) + x(2) + ... + x(n) >= n
    #
    # @param [Array] participant_ids
    # @return [IlpConditionRow]
    def create_and_condition(participant_ids)
      raise 'Array of 1 or more participants must be provided!' unless participant_ids.kind_of?(Array) && participant_ids.length >= 1

      condition_array = create_empty_condition_array
      right_side_value = participant_ids.length

      participant_ids.each do |participant_id|
        participant_event_index = IlpPlanner::PlannerService.get_event_participant_id(@event.id, participant_id)
        condition_array[participant_event_index] = 1
      end

      IlpConditionRow.new(condition_array, IlpPlanner::EqualityTypes::MORE_OR_EQUAL, right_side_value)
    end

    # Creates n-ary OR condition
    #
    # Modeled by: x(1) + x(2) + ... + x(n) >= 1
    #
    # @param [Array] participant_ids
    # @return [IlpConditionRow]
    def create_or_condition(participant_ids)
      raise 'Array of 2 or more participants must be provided!' unless participant_ids.kind_of?(Array) && participant_ids.length >= 2

      condition_array = create_empty_condition_array
      right_side_value = 1

      participant_ids.each do |participant_id|
        participant_event_index = IlpPlanner::PlannerService.get_event_participant_id(@event.id, participant_id)
        condition_array[participant_event_index] = 1
      end

      IlpConditionRow.new(condition_array, IlpPlanner::EqualityTypes::MORE_OR_EQUAL, right_side_value)
    end


    private

      def create_empty_condition_array
        Array.new(@matrix_information.n, 0)
      end

  end

  class IlpConditionRow
    attr_reader :row_values, :equality_operator, :right_side_value

    def initialize(row_values, equality_operator, right_side_value)
      @row_values = row_values
      @equality_operator = equality_operator
      @right_side_value = right_side_value
    end
  end
end