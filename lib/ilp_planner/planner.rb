module IlpPlanner
  class Planner

    def initialize
      @event = nil
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

    def self.plan (event_id)
      event = Event.find(event_id)
      results = []

      event.slots.each_with_index do |slot, index|
        slot_planner = IlpPlanner::Planner.new

        # TODO store results and get the best one
        results << slot_planner.plan_slot(slot)
      end

      results
    end

    def plan_slot(slot)
      setup_new_calculation_for(slot)
      build_ilp_structures
      create_rglpk_problem

      solve_plan_slot_get_result

      # TODO remove in production
      write_debug_files
    end

    private

    def write_debug_files
      file_path = '/tmp/smart_event_scheduling_debug/'
      Dir.mkdir(file_path) unless Dir.exist? file_path

      filename = "e##{@event.id}_s##{@slot.id}.txt"

      @glpk.write_lp(file_path + filename)
    end

    def solve_plan_slot_get_result
      puts 'Running simplex calculation ...'
      @glpk.simplex
      puts 'Calculation ended'

      z = @glpk.obj.get

      results = [z]
      @glpk_cols.each do |col|
        results << col.get_prim
      end

      results
    end

    def setup_new_calculation_for(slot)
      @event = slot.event
      @slot = slot

      @matrix_information = IlpPlanner::PlannerService.calc_matrix_information_for_event(@event)

      # init structures - A, b
      (0..@matrix_information.m-1).each { |row_index| @a_matrix[row_index] = Array.new(@matrix_information.n, 0) }
      @criterial_function_coefficients = Array.new(@matrix_information.n, 0)

      create_a_matrix_columns
    end

    # Builds A matrix, b vector, calculates participant ratings
    def build_ilp_structures
      @participant_wish_ratings = IlpPlanner::PlannerService.calc_participant_wish_ratings(@event)

      participant_ids = IlpPlanner::PlannerService.get_participant_ids(@event.id)

      # criterial function coefficients

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
        end
      end

      preference_condition_creator = IlpPlanner::PreferenceConditionCreator.new(@event)

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
            @a_matrix_rows[index] = IlpMatrixRow.new("condition[\##{condition.id}]", rglpk_equality, 0, condition_row.right_side_value) # TODO

          when IlpPlanner::EqualityTypes::GREATER_OR_EQUAL_THAN then
            rglpk_equality = Rglpk::GLP_LO
            @a_matrix_rows[index] = IlpMatrixRow.new("condition[\##{condition.id}]", rglpk_equality, condition_row.right_side_value, 0) # TODO

          else
            raise 'Equality not implemented error'
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