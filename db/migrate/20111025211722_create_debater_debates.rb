class CreateDebaterDebates < ActiveRecord::Migration
  def change
    create_table :debater_debates do |t|
      t.integer :debater_id
      t.integer :debate_id

      t.timestamps
    end
  end
end
