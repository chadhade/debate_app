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

ActiveRecord::Schema.define(:version => 20120326025732) do

  create_table "arguments", :force => true do |t|
    t.integer  "debater_id"
    t.integer  "debate_id"
    t.text     "content"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "time_left"
    t.boolean  "Repeat_Turn"
    t.boolean  "any_footnotes"
    t.text     "content_foot",  :limit => 255
    t.boolean  "debate_over"
    t.text     "image_url"
  end

  add_index "arguments", ["debate_id"], :name => "index_arguments_on_debate_id"
  add_index "arguments", ["debater_id"], :name => "index_arguments_on_debater_id"

  create_table "blockings", :force => true do |t|
    t.integer  "blocker_id"
    t.integer  "blocked_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_borrowed"
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
    t.integer  "arg_upvotes",                           :default => 0
    t.integer  "arg_downvotes",                         :default => 0
    t.integer  "waiting_for"
    t.integer  "judge_points",                          :default => 0
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.integer  "failed_attempts",                       :default => 0
    t.string   "unlock_token"
    t.datetime "locked_at"
    t.datetime "last_request_at"
    t.integer  "rating"
  end

  add_index "debaters", ["confirmation_token"], :name => "index_debaters_on_confirmation_token", :unique => true
  add_index "debaters", ["email"], :name => "index_debaters_on_email", :unique => true
  add_index "debaters", ["name"], :name => "index_debaters_on_name", :unique => true
  add_index "debaters", ["reset_password_token"], :name => "index_debaters_on_reset_password_token", :unique => true
  add_index "debaters", ["sign_in_count"], :name => "index_debaters_on_sign_in_count"
  add_index "debaters", ["unlock_token"], :name => "index_debaters_on_unlock_token", :unique => true

  create_table "debates", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "joined"
    t.boolean  "judge"
    t.datetime "joined_at"
    t.datetime "end_time"
    t.integer  "end_single_id"
    t.integer  "winner_id"
    t.integer  "loser_id"
    t.integer  "creator_id"
    t.integer  "joiner_id"
    t.integer  "judge_id"
    t.datetime "started_at"
    t.integer  "no_judge",      :default => 0
  end

  add_index "debates", ["creator_id"], :name => "index_debates_on_creator_id"
  add_index "debates", ["joiner_id"], :name => "index_debates_on_joiner_id"
  add_index "debates", ["judge", "joined"], :name => "index_debates_on_judge_and_joined"
  add_index "debates", ["started_at"], :name => "index_debates_on_started_at"

  create_table "debations", :force => true do |t|
    t.integer  "debater_id"
    t.integer  "debate_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "debations", ["debate_id"], :name => "index_debations_on_debate_id"
  add_index "debations", ["debater_id"], :name => "index_debations_on_debater_id"

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

  create_table "judgings", :force => true do |t|
    t.integer  "debater_id"
    t.integer  "debate_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "winner_id"
    t.text     "comments"
    t.integer  "loser_id"
    t.boolean  "winner_approve"
    t.boolean  "loser_approve"
  end

  add_index "judgings", ["debate_id"], :name => "index_judgings_on_debate_id"
  add_index "judgings", ["debater_id"], :name => "index_judgings_on_debater_id"

  create_table "relationships", :force => true do |t|
    t.integer  "follower_id"
    t.integer  "followed_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "teammate"
  end

  add_index "relationships", ["followed_id"], :name => "index_relationships_on_followed_id"
  add_index "relationships", ["follower_id"], :name => "index_relationships_on_follower_id"

  create_table "suggested_topics", :force => true do |t|
    t.string   "topic"
    t.decimal  "rating",     :default => 1.0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "suggested_topics", ["rating"], :name => "index_suggested_topics_on_rating"

  create_table "topic_positions", :force => true do |t|
    t.integer  "debater_id"
    t.integer  "debate_id"
    t.string   "topic"
    t.boolean  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "topic_positions", ["debate_id"], :name => "index_topic_positions_on_debate_id"

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
    t.boolean  "creator"
    t.boolean  "joiner"
  end

  add_index "viewings", ["currently_viewing", "creator"], :name => "index_viewings_on_currently_viewing_and_creator"
  add_index "viewings", ["debate_id"], :name => "index_viewings_on_debate_id"
  add_index "viewings", ["viewer_id"], :name => "index_viewings_on_viewer_id"

  create_table "votes", :force => true do |t|
    t.boolean  "vote",          :default => false
    t.integer  "voteable_id",                      :null => false
    t.string   "voteable_type",                    :null => false
    t.integer  "voter_id"
    t.string   "voter_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "votes", ["voteable_id"], :name => "index_votes_on_voteable_id"
  add_index "votes", ["voter_id"], :name => "index_votes_on_voter_id"

end
