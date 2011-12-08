# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20111208005833) do

  create_table "arguments", :force => true do |t|
    t.integer  "debater_id"
    t.integer  "debate_id"
    t.text     "content"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "time_left"
    t.boolean  "Repeat_Turn"
    t.boolean  "any_footnotes"
    t.string   "content_foot"
  end

  create_table "blockings", :force => true do |t|
    t.integer  "blocker_id"
    t.integer  "blocked_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "blockings", ["blocked_id"], :name => "index_blockings_on_blocked_id"
  add_index "blockings", ["blocker_id"], :name => "index_blockings_on_blocker_id"

  create_table "debaters", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "email",                                 :default => "", :null => false
    t.string   "encrypted_password",     :limit => 128, :default => "", :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                         :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
  end

  add_index "debaters", ["email"], :name => "index_debaters_on_email", :unique => true
  add_index "debaters", ["reset_password_token"], :name => "index_debaters_on_reset_password_token", :unique => true

  create_table "debates", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "debations", :force => true do |t|
    t.integer  "debater_id"
    t.integer  "debate_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "footnotes", :force => true do |t|
    t.string  "content"
    t.integer "argument_id"
    t.integer "position"
    t.integer "foot_count"
  end

  add_index "footnotes", ["argument_id"], :name => "index_footnotes_on_argument_id"

  create_table "ips", :force => true do |t|
    t.string   "IP_address"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "relationships", :force => true do |t|
    t.integer  "follower_id"
    t.integer  "followed_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "relationships", ["followed_id"], :name => "index_relationships_on_followed_id"
  add_index "relationships", ["follower_id"], :name => "index_relationships_on_follower_id"

  create_table "trackings", :force => true do |t|
    t.integer  "debater_id"
    t.integer  "debate_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "viewings", :force => true do |t|
    t.integer  "debate_id"
    t.integer  "viewer_id"
    t.string   "viewer_type"
    t.boolean  "currently_viewing"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "votes", :force => true do |t|
    t.boolean  "vote",          :default => false
    t.integer  "voteable_id",                      :null => false
    t.string   "voteable_type",                    :null => false
    t.integer  "voter_id"
    t.string   "voter_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "votes", ["voteable_id", "voteable_type"], :name => "index_votes_on_voteable_id_and_voteable_type"
  add_index "votes", ["voter_id", "voter_type"], :name => "index_votes_on_voter_id_and_voter_type"

end
