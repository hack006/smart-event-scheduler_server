# Index range
#
# @attr_accessor [Integer] :start_index
# @attr_accessor [Integer] :end_index
class IndexRange
  attr_accessor :start_index, :end_index

  def initialize(start_index, end_index)
    @start_index = start_index
    @end_index = end_index
  end

  # Iterates through all indexes in the range
  #
  # @yield [index, index_index] Description of block
  # @yieldparam [Integer] index index value given from the range
  # @yieldparam [Integer] index_index index of current index, starts at 0, ends at range.length-1
  def each_index(&block)
    for i in @start_index..@end_index do
      block.call i, i - @start_index
    end
  end

  # Get length of the interval
  #
  # @return [Integer] length
  def length
    return [0, 1 + @end_index - @start_index].max
  end
end