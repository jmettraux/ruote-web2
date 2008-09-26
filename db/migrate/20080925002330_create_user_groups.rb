
class CreateUserGroups < ActiveRecord::Migration

  def self.up
    create_table :user_groups do |t|
      t.integer :user_id, :null => false
      t.integer :group_id, :null => false
    end
    add_index :user_groups, [ :user_id, :group_id ], :unique => true
  end

  def self.down
    drop_table :user_groups
  end
end

