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
      @b_vector = []
    end

    def plan (event_id)
      setup_new_calculation_for(event_id)
      build_ilp_structures
      create_rglpk_problem
    end

    def get_results
      puts 'Running simplex calculation ...'
      @glpk.simplex
      puts 'Calculation ended'

      z = @glpk.obj.get

      results = [z]
      @glpk_rows.each do |row|
        results << row.get_prim
      end

      results
    end

    private
      def setup_new_calculation_for(event_id)
        @event = Event.find(event_id)

        @matrix_information = IlpPlanner::PlannerService.calc_matrix_information_for_event(@event)

        # init structures - A, b
        (0..@matrix_information.m-1).each{|row_index| @a_matrix[row_index] = Array.new(@matrix_information.n, 0) }
        @b_vector = Array.new(@matrix_information.m, 0)

        create_a_matrix_columns
      end

      # Builds A matrix, b vector, calculates participant ratings
      def build_ilp_structures
        @participant_wish_ratings = IlpPlanner::PlannerService.calc_participant_wish_ratings(@event)

        participant_ids = IlpPlanner::PlannerService.get_participant_ids(@event.id)

        # fill each slot
        @event.slots.each_with_index do |slot, slot_index|
          slot_range = @matrix_information.slot_ranges[slot.id]

          slot_availabilities_by_participant_id = {}
          participant_ids.each do |participant_id|
            slot_availabilities_by_participant_id[participant_id] = AvailabilityStatuses::DEFAULT
          end

          slot.availabilities.each do |availability|
            slot_availabilities_by_participant_id[availability.participant_id] = availability.status
          end

          (slot_range.start..slot_range.stop).each_with_index do |column_index, index|
            slot_participant_id = participant_ids[index]

            if slot_availabilities_by_participant_id[slot_participant_id] == AvailabilityStatuses::AVAILABLE
              ci = @participant_wish_ratings[slot_participant_id]
              @a_matrix[slot_index][column_index] = ci
            else
              # already set 0 by default
            end

          end

          # last column holding MIN used to find maximum
          @a_matrix[slot_index][@matrix_information.n-1] = -1

          @b_vector[slot_index] = 0
          @a_matrix_rows[slot_index] = IlpMatrixRow.new("slot[#{slot.id}]", Rglpk::GLP_UP, 0, 0)
        end
      end

      def create_rglpk_problem
        @glpk = Rglpk::Problem.new
        @glpk.name = "Scheduling best event date for [event:\##{@event.id}]"
        @glpk.obj.dir = Rglpk::GLP_MIN

        # rows
        @glpk_rows = @glpk.add_rows(@matrix_information.m)
        @a_matrix_rows.each_with_index do |row, index|
          @glpk_rows[index].name = row.name
          @glpk_rows[index].set_bounds(row.bound_type, row.lower_bound, row.upper_bound)
        end

        # columns
        @glpk_cols = @glpk.add_cols(@matrix_information.n)
        @a_matrix_columns.each_with_index do |column, index|
          @glpk_cols[index].name  = column.name
          @glpk_cols[index].set_bounds(column.bound_type, column.lower_bound, column.upper_bound)
          @glpk_cols[index].kind = column.variable_type
        end

        # c(j) values
        criterial_function_coeficients = Array.new(@matrix_information.n - 1, 0) + [1]
        @glpk.obj.coefs = criterial_function_coeficients

        # A(i,j)
        @glpk.set_matrix(@a_matrix.flatten)

      end

      def create_a_matrix_columns
        participant_ids = IlpPlanner::PlannerService.get_participant_ids(@event.id)

        @matrix_information.slot_ids_asc.each do |slot_id|
          slot_range = @matrix_information.slot_ranges[slot_id]

          (slot_range.start..slot_range.stop).each_with_index do |slot_column_index, index|
              @a_matrix_columns[slot_column_index] = IlpMatrixColumn.new("s#{slot_id}p#{participant_ids[index]}", Rglpk::GLP_LO, 0, 0, Rglpk::GLP_BV)
          end
        end

        @a_matrix_columns[@matrix_information.n-1] = IlpMatrixColumn.new('MIN', Rglpk::GLP_LO, 0, 0, Rglpk::GLP_CV)
      end
  end
end