class Event < ActiveRecord::Base
  extend FriendlyId
  friendly_id :slug_candidates, use: :slugged # generate random sequence

  belongs_to :manager, class_name: 'User', :foreign_key => :manager_id
  has_many :participants
  has_many :slots

  validates :name, presence: true,
            length: {minimum: 3}
  validates :manager_id, presence: true

  def slug_candidates
    return ['']
  end
end
