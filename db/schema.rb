# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20080925002330) do

  create_table "fields", :force => true do |t|
    t.string  "fkey",        :default => "", :null => false
    t.string  "vclass",      :default => "", :null => false
    t.string  "svalue"
    t.text    "yvalue"
    t.integer "workitem_id",                 :null => false
  end

  add_index "fields", ["workitem_id", "fkey"], :name => "index_fields_on_workitem_id_and_fkey", :unique => true
  add_index "fields", ["fkey"], :name => "index_fields_on_fkey"
  add_index "fields", ["vclass"], :name => "index_fields_on_vclass"
  add_index "fields", ["svalue"], :name => "index_fields_on_svalue"

  create_table "groups", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "history", :force => true do |t|
    t.datetime "created_at"
    t.string   "source",      :default => "", :null => false
    t.string   "event",       :default => "", :null => false
    t.string   "wfid"
    t.string   "fei"
    t.string   "participant"
    t.string   "message"
  end

  add_index "history", ["created_at"], :name => "index_history_on_created_at"
  add_index "history", ["source"], :name => "index_history_on_source"
  add_index "history", ["event"], :name => "index_history_on_event"
  add_index "history", ["wfid"], :name => "index_history_on_wfid"
  add_index "history", ["participant"], :name => "index_history_on_participant"

  create_table "user_groups", :force => true do |t|
    t.integer "user_id",  :null => false
    t.integer "group_id", :null => false
  end

  create_table "users", :force => true do |t|
    t.string   "login",                     :limit => 40
    t.string   "name",                      :limit => 100, :default => "", :null => false
    t.string   "email",                     :limit => 100
    t.string   "crypted_password",          :limit => 40
    t.string   "salt",                      :limit => 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "remember_token",            :limit => 40
    t.datetime "remember_token_expires_at"
  end

  add_index "users", ["login"], :name => "index_users_on_login", :unique => true

  create_table "workitems", :force => true do |t|
    t.string   "fei"
    t.string   "wfid"
    t.string   "wf_name"
    t.string   "wf_revision"
    t.string   "participant_name"
    t.string   "store_name"
    t.datetime "dispatch_time"
    t.datetime "last_modified"
    t.text     "yattributes"
  end

  add_index "workitems", ["fei"], :name => "index_workitems_on_fei", :unique => true
  add_index "workitems", ["wfid"], :name => "index_workitems_on_wfid"
  add_index "workitems", ["wf_name"], :name => "index_workitems_on_wf_name"
  add_index "workitems", ["wf_revision"], :name => "index_workitems_on_wf_revision"
  add_index "workitems", ["participant_name"], :name => "index_workitems_on_participant_name"
  add_index "workitems", ["store_name"], :name => "index_workitems_on_store_name"

end
