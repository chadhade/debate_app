class CreateViewings < ActiveRecord::Migration
  def change
    create_table :viewings do |t|
      t.integer :debate_id
      t.integer :viewer_id
      t.string :viewer_type
      t.boolean :currently_viewing

      t.timestamps
    end
  end
end
