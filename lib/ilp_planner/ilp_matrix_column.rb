class IlpMatrixColumn
  attr_accessor :name, :bound_type, :lower_bound, :upper_bound, :variable_type

  # @param [String] name
  # @param [Integer] bound_type Possible values { Rglpk::GLP_UP, Rglpk::GLP_LO }
  # @param [Numeric] lower_bound
  # @param [Numeric] upper_bound
  # @param [Integer] variable_type possible values { Rglpk::GLP_CV - continuous variable, Rglpk::GLP_IV - integer variable, Rglpk::GLP_BV - binary variable }
  def initialize(name, bound_type, lower_bound, upper_bound, variable_type)
    @name = name
    @bound_type = bound_type
    @lower_bound = lower_bound
    @upper_bound = upper_bound
    @variable_type = variable_type
  end
end