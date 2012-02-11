class CreateSuggestedTopics < ActiveRecord::Migration
  def change
    create_table :suggested_topics do |t|
      t.string :topic
      t.string :topic2
      t.decimal :rating, :precision => 5, :scale => 3, :default => 1
      
      t.timestamps
    end
  end
end
