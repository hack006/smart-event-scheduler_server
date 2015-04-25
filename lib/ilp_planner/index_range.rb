# Store index range given from :start to :end

# @attr_accessor [Integer] :start index of the interval
# @attr_accessor [Integer] :end index of the interval
class IndexRange
  attr_accessor :start
  attr_accessor :stop

  # @param [Integer] :start_index
  # @param [Integer] :stop_index
  def initialize(start_index, stop_index)
    raise 'Error! Negative index given.' if start_index < 0 || stop_index < 0

    @start = start_index
    @stop = stop_index
  end
end