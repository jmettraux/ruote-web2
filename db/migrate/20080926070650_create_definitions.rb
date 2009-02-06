
class CreateDefinitions < ActiveRecord::Migration

  def self.up
    create_table :definitions do |t|
      t.string :name
      t.string :description
      t.string :uri
      t.text :launch_fields
      t.timestamps
    end
    add_index :definitions, :name, :unique => true
  end

  def self.down
    drop_table :definitions
  end
end

