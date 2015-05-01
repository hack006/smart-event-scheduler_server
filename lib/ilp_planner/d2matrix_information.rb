# Stores information about matrix used to solve meeting problem
#
# @attr_reader [Integer] :m number of rows
# @attr_reader [Integer] :n number of rows
class D2MatrixInformation
  attr_reader :m
  attr_reader :n

  # @param [Integer] m
  # @param [Integer] n
  def initialize(m, n)
    @m = m
    @n = n
  end
end