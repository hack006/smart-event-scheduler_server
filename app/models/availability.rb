class Availability < ActiveRecord::Base

  belongs_to :slot
  belongs_to :participant

  validates :status, inclusion: {in: AvailabilityStatuses::to_string_a},
            presence: true
  validates_uniqueness_of :participant_id, scope: :slot_id
end
