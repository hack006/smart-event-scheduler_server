module PreferencePrioritizationMultipliers
  extend Enum

  WANT_TO_SEE = 5
  NICE_TO_SEE = 3
  DO_NOT_CARE = 1
  WANT_NOT_TO_SEE = - 2

  DEFAULT = DO_NOT_CARE
end