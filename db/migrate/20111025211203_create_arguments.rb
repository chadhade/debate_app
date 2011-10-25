class CreateArguments < ActiveRecord::Migration
  def change
    create_table :arguments do |t|
      t.integer :debater_id
      t.integer :debate_id
      t.text :content

      t.timestamps
    end
  end
end
