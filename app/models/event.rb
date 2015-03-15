class Event < ActiveRecord::Base
  belongs_to :manager, class_name: 'User', :foreign_key => :manager_id
  has_many :participants
  has_many :slots

  validates :name, presence: true,
            length: {minimum: 3}
  validates :manager_id, presence: true
end
