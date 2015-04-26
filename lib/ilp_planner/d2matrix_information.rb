require_relative 'index_range'

# Stores information about matrix used to solve meeting problem
#
# @attr_reader [Integer] :m number of rows
# @attr_reader [Integer] :n number of rows
# @attr_reader [Hash<slot_id:Integer, range:IndexRange>] :slot_ranges
# @attr_reader [Array<Integer>] :slot_ids_asc sorted array of slot ids used in slot_ranges
class D2MatrixInformation
  attr_reader :m
  attr_reader :n
  attr_reader :slot_ranges
  attr_reader :slot_ids_asc

  # @param [Integer] m
  # @param [Integer] n
  # @param [Hash<Integer, IndexRange>] slot_ranges
  # @param [Array<Integer>] slot_ids_asc
  def initialize(m, n, slot_ranges, slot_ids_asc)
    @m = m
    @n = n
    @slot_ranges = slot_ranges
    @slot_ids_asc = slot_ids_asc
  end
end