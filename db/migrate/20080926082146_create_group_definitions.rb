
class CreateGroupDefinitions < ActiveRecord::Migration

  def self.up
    create_table :group_definitions do |t|
      t.integer :group_id
      t.integer :definition_id

      t.timestamps
    end
  end

  def self.down
    drop_table :group_definitions
  end
end

