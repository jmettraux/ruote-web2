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

ActiveRecord::Schema.define(:version => 20090119093821) do

  create_table "ar_workitems", :force => true do |t|
    t.string   "fei"
    t.string   "wfid"
    t.string   "expid"
    t.string   "wfname"
    t.string   "wfrevision"
    t.string   "participant_name"
    t.string   "store_name"
    t.datetime "dispatch_time"
    t.datetime "last_modified"
    t.text     "wi_fields"
    t.string   "activity"
    t.text     "keywords"
  end

  add_index "ar_workitems", ["expid"], :name => "index_ar_workitems_on_expid"
  add_index "ar_workitems", ["fei"], :name => "index_ar_workitems_on_fei", :unique => true
  add_index "ar_workitems", ["participant_name"], :name => "index_ar_workitems_on_participant_name"
  add_index "ar_workitems", ["store_name"], :name => "index_ar_workitems_on_store_name"
  add_index "ar_workitems", ["wfid"], :name => "index_ar_workitems_on_wfid"
  add_index "ar_workitems", ["wfname"], :name => "index_ar_workitems_on_wfname"
  add_index "ar_workitems", ["wfrevision"], :name => "index_ar_workitems_on_wfrevision"

  create_table "definitions", :force => true do |t|
    t.string   "name"
    t.string   "description"
    t.string   "uri"
    t.text     "launch_fields"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "definitions", ["name"], :name => "index_definitions_on_name", :unique => true

  create_table "group_definitions", :force => true do |t|
    t.integer  "group_id"
    t.integer  "definition_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "groups", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "groups", ["name"], :name => "index_groups_on_name", :unique => true

  create_table "history", :force => true do |t|
    t.datetime "created_at"
    t.string   "source",      :null => false
    t.string   "event",       :null => false
    t.string   "wfid"
    t.string   "wfname"
    t.string   "wfrevision"
    t.string   "fei"
    t.string   "participant"
    t.string   "message"
  end

  add_index "history", ["created_at"], :name => "index_history_on_created_at"
  add_index "history", ["event"], :name => "index_history_on_event"
  add_index "history", ["participant"], :name => "index_history_on_participant"
  add_index "history", ["source"], :name => "index_history_on_source"
  add_index "history", ["wfid"], :name => "index_history_on_wfid"
  add_index "history", ["wfname"], :name => "index_history_on_wfname"
  add_index "history", ["wfrevision"], :name => "index_history_on_wfrevision"

  create_table "process_errors", :force => true do |t|
    t.datetime "created_at"
    t.string   "wfid",       :null => false
    t.string   "expid",      :null => false
    t.text     "svalue",     :null => false
  end

  add_index "process_errors", ["created_at"], :name => "index_process_errors_on_created_at"
  add_index "process_errors", ["expid"], :name => "index_process_errors_on_expid"
  add_index "process_errors", ["wfid"], :name => "index_process_errors_on_wfid"

  create_table "user_groups", :force => true do |t|
    t.integer "user_id",  :null => false
    t.integer "group_id", :null => false
  end

  add_index "user_groups", ["user_id", "group_id"], :name => "index_user_groups_on_user_id_and_group_id", :unique => true

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

end
