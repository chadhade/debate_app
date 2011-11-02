# encoding: UTF-8
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

ActiveRecord::Schema.define(:version => 20111102000047) do

  create_table "arguments", :force => true do |t|
    t.integer  "debater_id"
    t.integer  "debate_id"
    t.text     "content"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "time_left"
  end

  create_table "debaters", :force => true do |t|
    t.string   "name"
    t.string   "encrypted_password"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

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
