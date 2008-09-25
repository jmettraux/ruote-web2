
class Group < ActiveRecord::Base

  has_many :user_groups
  has_many :users, :through => :user_groups
end

