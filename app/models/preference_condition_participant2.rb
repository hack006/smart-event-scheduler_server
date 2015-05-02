class PreferenceConditionParticipant2 < ActiveRecord::Base
  belongs_to :preference_condition
  belongs_to :participant
end