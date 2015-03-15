class User < ActiveRecord::Base
  has_many :managed_events, :class_name => 'Event', :foreign_key => :manager_id

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
end