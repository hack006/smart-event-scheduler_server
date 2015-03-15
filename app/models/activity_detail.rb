class ActivityDetail < ActiveRecord::Base
  belongs_to :event
  has_many :slots

  validates :name, presence: true
  validates :price_per_unit, presence: { if: :price_not_empty?, message: 'You have to specify unit for the price'}

  def price_not_empty?
    return !price.blank?
  end
end
