class Participant < ActiveRecord::Base
  belongs_to :user
  belongs_to :event
  has_many :availabilities
  has_many :preferences

  validates :user_id, presence: true
end
