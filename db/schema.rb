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

ActiveRecord::Schema.define(:version => 20111102191614) do

  create_table "arguments", :force => true do |t|
    t.integer  "debater_id"
    t.integer  "debate_id"
    t.text     "content"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "time_left"
    t.boolean  "Repeat_Turn"
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

end
