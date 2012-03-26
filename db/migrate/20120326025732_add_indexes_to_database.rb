class AddIndexesToDatabase < ActiveRecord::Migration
  def change
    remove_index :votes, :column => [:voter_id, :voter_type]
    remove_index :votes, :column => [:voteable_id, :voteable_type]
    add_index :votes, :voter_id
    add_index :votes, :voteable_id
    add_index :debaters, :name, :unique => true
    add_index :debaters, :sign_in_count
    add_index :topic_positions, :debate_id
    add_index :debates, :started_at
    add_index :debates, :creator_id
    add_index :debates, :joiner_id
    add_index :debates, [:judge, :joined]
    add_index :debations, :debater_id
    add_index :debations, :debate_id
    add_index :judgings, :debate_id
    add_index :judgings, :debater_id
    add_index :suggested_topics, :rating
    add_index :arguments, :debate_id
    add_index :arguments, :debater_id
    add_index :viewings, :debate_id
    add_index :viewings, :viewer_id
    add_index :viewings, [:currently_viewing, :creator]    
  end
end
