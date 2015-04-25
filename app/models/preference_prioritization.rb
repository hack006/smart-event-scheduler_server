class PreferencePrioritization < ActiveRecord::Base
  belongs_to :participant, class_name: Participant, :foreign_key => :participant_id
  belongs_to :for_participant, class_name: Participant, :foreign_key => :for_participant_id

  validates :participant_id, :presence => true
  validates :for_participant_id, :presence => true
  validates :multiplier, :presence => true, :numericality => true
end