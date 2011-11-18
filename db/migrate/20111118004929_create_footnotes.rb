class CreateFootnotes < ActiveRecord::Migration
  def change
    create_table :footnotes do |t|
      t.string :content
      t.integer :argument_id	
	end
	add_index :footnotes, :argument_id
  end
end
