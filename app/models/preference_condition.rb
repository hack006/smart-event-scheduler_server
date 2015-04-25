class PreferenceCondition < ActiveRecord::Base

  belongs_to :owner_participant, foreign_key: :participant_id
  belongs_to :participant1, class: User, foreign_key: :participant1_id
  belongs_to :participant2, class: User, foreign_key: :participant2_id

  validates :condition_type, inclusion: {in: PreferenceTypes.to_string_a},
      presence: true
end
