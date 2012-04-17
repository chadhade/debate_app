class AddTopicDToSuggestedTopics < ActiveRecord::Migration
  def change
    add_column :suggested_topics, :topicd, :string
    
    remove_index :suggested_topics, :column => :rating
    add_index :suggested_topics, :topicd
    
  end
end
