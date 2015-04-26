require_relative 'planner_service'
require_relative 'ilp_matrix_column'
require_relative 'ilp_matrix_row'

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
      @b_vector = []
    end

    def self.plan (event_id)
      event = Event.find(event_id)
      results = []

      event.slots.each_with_index do |slot, index|
        slot_planner = IlpPlanner::Planner.new
        slot_planner.plan_slot(slot)
        # TODO store results and get the best one
        results << slot_planner.solve_plan_slot_get_result
      end

      results
    end

    def plan_slot(slot)
      setup_new_calculation_for(slot)
      build_ilp_structures
      create_rglpk_problem
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

    private

      def setup_new_calculation_for(slot)
        @event = slot.event
        @slot = slot

        @matrix_information = IlpPlanner::PlannerService.calc_matrix_information_for_slot(@slot)

        # init structures - A, b
        (0..@matrix_information.m-1).each { |row_index| @a_matrix[row_index] = Array.new(@matrix_information.n, 0) }
        @b_vector = Array.new(@matrix_information.m, 0)
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

        PreferenceCondition.where('participant_id IN (?)', participant_ids).each_with_index do |condition, index|
          # TODO A matrix
          #@a_matrix[index][some_row] = ?

          @b_vector[index] = 0
          @a_matrix_rows[index] = IlpMatrixRow.new("condition[\##{@slot.id}]", Rglpk::GLP_UP, 0, 9999)
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

        # A(i,j)
        @glpk.set_matrix(@a_matrix.flatten)

      end

      def create_a_matrix_columns
        participant_ids = IlpPlanner::PlannerService.get_participant_ids(@event.id)

        participant_ids.each_with_index do |participant_id, index|
          @a_matrix_columns[index] = IlpMatrixColumn.new("p#{participant_id}", Rglpk::GLP_LO, 0, 0, Rglpk::GLP_BV)
        end
      end
  end
end