class Availability < ActiveRecord::Base
  AVAILABILITY_TYPES = %w(can cant) # TODO extend in the future

  belongs_to :slot
  belongs_to :participant

  validates :status, inclusion: {in: AVAILABILITY_TYPES},
            presence: true
  validates_uniqueness_of :participant_id, scope: :slot_id
end
