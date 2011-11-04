class CreateTrackings < ActiveRecord::Migration
  def change
    create_table :trackings do |t|
      t.integer :debater_id
      t.integer :debate_id

      t.timestamps
    end
  end
end
