class ActivityDetail < ActiveRecord::Base
  belongs_to :event
  has_many :slots

  validates :name, presence: true
  validates :price_unit, presence: { if: :price_not_empty?, message: 'You have to specify price unit.'}
  validates :price_per_unit, presence: { if: :price_not_empty?, message: 'You have to specify time duration.'}

  def price_not_empty?
    return !price.blank?
  end
end
