# Stores information about matrix used to solve meeting problem
#
# @attr_reader [Integer] :m number of rows
# @attr_reader [Integer] :n number of rows
# @attr_reader [IndexRange] :unavailability_conditions_range index range where unavailability constrains of participants are given
# @attr_reader [IndexRange] :required_count_conditions_range index range where required counts are given
class D2MatrixInformation
  attr_reader :m, :n, :unavailability_conditions_range, :required_count_conditions_range

  # @param [Integer] m
  # @param [Integer] n
  # @param [IndexRange] unavailability_conditions_range
  # @param [IndexRange] required_count_conditions_range
  def initialize(m, n, unavailability_conditions_range, required_count_conditions_range)
    @m = m
    @n = n
    @unavailability_conditions_range = unavailability_conditions_range
    @required_count_conditions_range = required_count_conditions_range
  end
end