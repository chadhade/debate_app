class AddContentFootnotesToArgument < ActiveRecord::Migration
  def change
	add_column :arguments, :content_foot, :string
  end
end
