class TimeDetail < ActiveRecord::Base
  belongs_to :event
  has_many :slots
end
