class Participant < ActiveRecord::Base
  belongs_to :user
  belongs_to :event
  has_many :availabilities
  has_many :preference_conditions
  has_many :preference_prioritizations

  validates :user_id, presence: true
end
