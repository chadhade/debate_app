class CreateJudgings < ActiveRecord::Migration
  def change
    create_table :judgings do |t|
      t.integer :debater_id
      t.integer :debate_id

      t.timestamps
    end
  end
end
