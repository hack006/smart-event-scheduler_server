class IlpMatrixRow
  attr_reader :name, :bound_type, :lower_bound, :upper_bound

  # @param [String] name
  # @param [Constant] bound_type Possible values {Rglpk::GLP_UP - '<=', Rglpk::GLP_LO - '>=', Rglpk::GLP_FX - '=='}
  # @param [Numeric] lower_bound
  # @param [Numeric] upper_bound
  def initialize name, bound_type, lower_bound, upper_bound
    @name = name
    @bound_type = bound_type
    @lower_bound = lower_bound
    @upper_bound = upper_bound
  end
end