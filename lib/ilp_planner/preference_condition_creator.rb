module IlpPlanner
  class PreferenceConditionCreator

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

      IlpConditionRow.new(condition_array, IlpPlanner::EqualityTypes::GREATER_OR_EQUAL_THAN, right_side_value)
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

      IlpConditionRow.new(condition_array, IlpPlanner::EqualityTypes::GREATER_OR_EQUAL_THAN, right_side_value)
    end

    # Creates (x(1) || x(2) || .. || x(n) ) => y condition
    #
    # Modeled by: x(1) + x(2) + .. + x(n) - n * y <= 0
    #   x(i), y := binary values
    #
    # @param [Array<Integer>] or_participant_ids
    # @param [Integer]implicated_participant_id
    # @return [IlpConditionRow]
    def create_multiple_or_implicate_condition(or_participant_ids, implicated_participant_id)

      condition_array = create_empty_condition_array
      right_side_value = 0

      or_participant_ids.each do |participant_id|
        participant_event_index = IlpPlanner::PlannerService.get_event_participant_id(@event.id, participant_id)
        condition_array[participant_event_index] = 1
      end

      implicated_participant_event_index = IlpPlanner::PlannerService.get_event_participant_id(@event.id, implicated_participant_id)
      condition_array[implicated_participant_event_index] = -1 * or_participant_ids.length

      IlpConditionRow.new(condition_array, IlpPlanner::EqualityTypes::LESS_OR_EQUAL_THAN, right_side_value)
    end

    # Creates (x(1) && x(2) && .. && x(n) ) => y condition
    #
    # Modeled by: x(1) + x(2) + .. + x(n) - y <= n - 1
    #   x(i), y := binary values
    #
    # @param [Array<Integer>] and_participant_ids
    # @param [Integer]implicated_participant_id
    # @return [IlpConditionRow]
    def create_multiple_and_implicate_condition(and_participant_ids, implicated_participant_id)

      condition_array = create_empty_condition_array
      right_side_value = and_participant_ids.length - 1

      and_participant_ids.each do |participant_id|
        participant_event_index = IlpPlanner::PlannerService.get_event_participant_id(@event.id, participant_id)
        condition_array[participant_event_index] = 1
      end

      implicated_participant_event_index = IlpPlanner::PlannerService.get_event_participant_id(@event.id, implicated_participant_id)
      condition_array[implicated_participant_event_index] = -1

      IlpConditionRow.new(condition_array, IlpPlanner::EqualityTypes::LESS_OR_EQUAL_THAN, right_side_value)
    end

    # Creates (!x(1) && !x(2) && .. && !x(n) ) => y condition
    #
    # Modeled by: x(1) + x(2) + .. + x(n) - y >= 0
    #   x(i), y := binary values
    #
    # @param [Array<Integer>] not_and_participant_ids
    # @param [Integer]implicated_participant_id
    # @return [IlpConditionRow]
    def create_multiple_not_and_implicate_condition(not_and_participant_ids, implicated_participant_id)

      condition_array = create_empty_condition_array
      right_side_value = 0

      not_and_participant_ids.each do |participant_id|
        participant_event_index = IlpPlanner::PlannerService.get_event_participant_id(@event.id, participant_id)
        condition_array[participant_event_index] = 1
      end

      implicated_participant_event_index = IlpPlanner::PlannerService.get_event_participant_id(@event.id, implicated_participant_id)
      condition_array[implicated_participant_event_index] = -1

      IlpConditionRow.new(condition_array, IlpPlanner::EqualityTypes::GREATER_OR_EQUAL_THAN, right_side_value)
    end

    private

      def create_empty_condition_array
        Array.new(@matrix_information.n, 0)
      end

  end

  # IlpConditionRow
  #
  # @attr_reader [Array] :row_coefficients
  # @attr_reader [String] :equality_operator
  # @attr_reader [Numeric] :right_side_value
  class IlpConditionRow
    attr_reader :row_coefficients, :equality_operator, :right_side_value

    def initialize(row_coefficients, equality_operator, right_side_value)
      @row_coefficients = row_coefficients
      @equality_operator = equality_operator
      @right_side_value = right_side_value
    end
  end
end