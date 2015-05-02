class PreferenceCondition < ActiveRecord::Base

  belongs_to :owner_participant, foreign_key: :participant_id

  has_and_belongs_to_many :participants1,
                          :join_table => 'preference_condition_participant1s',
                          :class_name => 'Participant'

  has_and_belongs_to_many :participants2,
                          :join_table => 'preference_condition_participant2s',
                          :class_name => 'Participant'


  validates :condition_type, inclusion: {in: PreferenceTypes.to_string_a},
            presence: true
end
