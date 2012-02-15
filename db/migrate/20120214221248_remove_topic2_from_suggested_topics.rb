class RemoveTopic2FromSuggestedTopics < ActiveRecord::Migration
  def change
    remove_column :suggested_topics, :topic2
  end
end
