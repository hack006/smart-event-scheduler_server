module IlpPlanner
  class SlotPlanner

    def initialize(slot)
      @slot = slot
      @event = @slot.event
      @participant_wish_ratings = []
      @matrix_information = nil

      @glpk = nil
      @glpk_rows = nil
      @glpk_cols = nil

      @a_matrix = []
      @a_matrix_rows = []
      @a_matrix_columns = []
      @criterial_function_coefficients = []
    end

    def self.plan_slot(slot)
      planner = IlpPlanner::SlotPlanner.new(slot)

      planner.plan
    end

    def plan
      setup_new_calculation
      build_ilp_structures
      create_rglpk_problem

      # TODO remove in production
      write_debug_files

      solve_plan_slot_get_result
    end

    private

    def write_debug_files
      file_path = '/tmp/smart_event_scheduling_debug/'
      Dir.mkdir(file_path) unless Dir.exist? file_path

      filename = "e##{@event.id}_s##{@slot.id}.txt"

      @glpk.write_lp(file_path + filename)
    end

    # @return [IlpPlanner::EventPlanningResult]
    def solve_plan_slot_get_result
      puts 'Running simplex calculation ...'
      @glpk.simplex
      puts 'Calculation ended'

      z = @glpk.obj.get

      variable_values = @glpk_cols.map do |col|
        col.get_prim
      end

      IlpPlanner::EventPlanningResult.new(@slot, z, variable_values)
    end

    def setup_new_calculation
      @matrix_information = IlpPlanner::PlannerService.calc_matrix_information_for_event(@slot)

      # init structures - A, b
      (0..@matrix_information.m-1).each { |row_index| @a_matrix[row_index] = Array.new(@matrix_information.n, 0) }
      @criterial_function_coefficients = Array.new(@matrix_information.n, 0)

      create_a_matrix_columns
    end

    # Builds A matrix, b vector, calculates participant ratings
    def build_ilp_structures
      @participant_wish_ratings = IlpPlanner::PlannerService.calc_participant_wish_ratings(@event)

      participant_ids = IlpPlanner::PlannerService.get_participant_ids(@event.id)
      unavailable_participant_ids = []

      build_ilp_criterial_function_coefficients(participant_ids, unavailable_participant_ids)

      build_ilp_preference_conditions(participant_ids)

      build_ilp_unavailability_constrains(unavailable_participant_ids)

      build_ilp_count_constrains

    end

    def build_ilp_criterial_function_coefficients(participant_ids, unavailable_participant_ids)
      slot_availability_by_participant_id = {}
      participant_ids.each do |participant_id|
        slot_availability_by_participant_id[participant_id] = AvailabilityStatuses::DEFAULT
      end

      @slot.availabilities.each do |availability|
        slot_availability_by_participant_id[availability.participant_id] = availability.status
      end

      participant_ids.each_with_index do |participant_id, index|
        if slot_availability_by_participant_id[participant_id] == AvailabilityStatuses::AVAILABLE
          @criterial_function_coefficients[index] = @participant_wish_ratings[participant_id]
        else
          unavailable_participant_ids << participant_id
        end
      end
    end

    def build_ilp_preference_conditions(participant_ids)
      preference_condition_creator = IlpPlanner::PreferenceConditionCreator.new(@slot)

      PreferenceCondition.where('participant_id IN (?)', participant_ids).each_with_index do |condition, index|

        condition_row = nil
        rglpk_equality = nil

        case condition.condition_type
          when PreferenceTypes::OR_IMPLICATE then
            or_participant_ids = condition.participants1.map { |p| p.id }
            implicate_participant_id = condition.participants2.first.id

            condition_row = preference_condition_creator.create_multiple_or_implicate_condition(or_participant_ids, implicate_participant_id)

          when PreferenceTypes::NOT_AND_IMPLICATE then
            not_and_participant_ids = condition.participants1.map { |p| p.id }
            implicate_participant_id = condition.participants2.first.id

            condition_row = preference_condition_creator.create_multiple_not_and_implicate_condition(not_and_participant_ids, implicate_participant_id)

          when PreferenceTypes::AND_IMPLICATE then
            and_participant_ids = condition.participants1.map { |p| p.id }
            implicate_participant_id = condition.participants2.first.id

            condition_row = preference_condition_creator.create_multiple_not_and_implicate_condition(and_participant_ids, implicate_participant_id)

          when PreferenceTypes::AND then
            and_participant_ids = condition.participants1.map { |p| p.id }

            condition_row = preference_condition_creator.create_and_condition(and_participant_ids)

          when PreferenceTypes::OR then
            or_participant_ids = condition.participants1.map { |p| p.id }

            condition_row = preference_condition_creator.create_or_condition(or_participant_ids)
        end

        @a_matrix[index] = condition_row.row_coefficients

        case condition_row.equality_operator
          when IlpPlanner::EqualityTypes::LESS_OR_EQUAL_THAN then
            rglpk_equality = Rglpk::GLP_UP
            @a_matrix_rows[index] = IlpMatrixRow.new("condition[\##{condition.id}]", rglpk_equality, 0, condition_row.right_side_value)

          when IlpPlanner::EqualityTypes::GREATER_OR_EQUAL_THAN then
            rglpk_equality = Rglpk::GLP_LO
            @a_matrix_rows[index] = IlpMatrixRow.new("condition[\##{condition.id}]", rglpk_equality, condition_row.right_side_value, 0)

          else
            raise 'Equality not implemented error'
        end

      end
    end

    def build_ilp_unavailability_constrains(unavailable_participant_ids)
      @matrix_information.unavailability_conditions_range.each_index do |position, position_index|
        participant_id = unavailable_participant_ids[position_index]
        event_participant_id = IlpPlanner::PlannerService.get_event_participant_id(@event.id, participant_id)

        @a_matrix[position][event_participant_id] = 1
        @a_matrix_rows[position] = IlpMatrixRow.new("condition_participant_unavailable[\##{event_participant_id}]", Rglpk::GLP_FX , 0, 0)
      end
    end

    def build_ilp_count_constrains
      # Participant count limits
      if @matrix_information.required_count_conditions_range.length != 0
        row_index = @matrix_information.required_count_conditions_range.start_index

        if @slot.activity_detail.minimum_count.present?
          minimum_participant_count = @slot.activity_detail.minimum_count

          @a_matrix[row_index] = Array.new(@matrix_information.n, 1)
          @a_matrix_rows[row_index] = IlpMatrixRow.new("paritipant_count[GEQ(#{minimum_participant_count})]", Rglpk::GLP_LO , minimum_participant_count, 0)

          row_index += 1
        end

        if @slot.activity_detail.maximum_count.present?
          maximum_participant_count = @slot.activity_detail.maximum_count

          @a_matrix[row_index] = Array.new(@matrix_information.n, 1)
          @a_matrix_rows[row_index] = IlpMatrixRow.new("paritipant_count[LEQ(#{maximum_participant_count})]", Rglpk::GLP_UP , 0, maximum_participant_count)
        end
      end
    end

    def create_rglpk_problem
      @glpk = Rglpk::Problem.new
      @glpk.name = "Scheduling best person combination for slot\##{@slot.id} for event\##{@event.id}]"
      @glpk.obj.dir = Rglpk::GLP_MAX

      # rows
      @glpk_rows = @glpk.add_rows(@matrix_information.m)
      @a_matrix_rows.each_with_index do |row, index|
        @glpk_rows[index].name = row.name
        @glpk_rows[index].set_bounds(row.bound_type, row.lower_bound, row.upper_bound)
      end

      # columns
      @glpk_cols = @glpk.add_cols(@matrix_information.n)
      @a_matrix_columns.each_with_index do |column, index|
        @glpk_cols[index].name = column.name
        @glpk_cols[index].set_bounds(column.bound_type, column.lower_bound, column.upper_bound)
        @glpk_cols[index].kind = column.variable_type
      end

      # c(j) values
      # todo
      @glpk.obj.coefs = @criterial_function_coefficients

      puts "Criterial coefficients: #{@criterial_function_coefficients}"

      # A(i,j)
      @glpk.set_matrix(@a_matrix.flatten)

    end

    def create_a_matrix_columns
      participant_ids = IlpPlanner::PlannerService.get_participant_ids(@event.id)

      participant_ids.each_with_index do |participant_id, index|
        @a_matrix_columns[index] = IlpMatrixColumn.new("p#{participant_id}", Rglpk::GLP_FR, 0, 0, Rglpk::GLP_BV)
      end
    end
  end
end