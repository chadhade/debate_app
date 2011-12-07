class CreateTopicPositions < ActiveRecord::Migration
  def change
    create_table :topic_positions do |t|
      t.integer :debater_id
      t.integer :debate_id
      t.string :topic
      t.boolean :position

      t.timestamps
    end
  end
end
