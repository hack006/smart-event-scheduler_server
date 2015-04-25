module Enum

  def to_string_a
    self.constants.map { |constant| self.const_get(constant) }
  end

end