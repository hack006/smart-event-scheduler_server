class Preference < ActiveRecord::Base
  PREFERENCE_TYPES = %w(not and or xor =>)
  belongs_to :participant, foreign_key: :participant_id
  belongs_to :user1, class: User, foreign_key: :user1_id
  belongs_to :user2, class: User, foreign_key: :user2_id

  validates :type, inclusion: {in: PREFERENCE_TYPES},
      presence: true
  validates :multiplier, minimum: -10, maximum: 10
end
