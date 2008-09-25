
#
# Between users and groups
#
class UserGroup < ActiveRecord::Base

  belongs_to :user
  belongs_to :group
end

