class Slot < ActiveRecord::Base
  belongs_to :event
  belongs_to :time_detail
  belongs_to :activity_detail
  has_many :availabilities

end
