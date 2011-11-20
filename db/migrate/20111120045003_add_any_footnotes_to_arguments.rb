class AddAnyFootnotesToArguments < ActiveRecord::Migration
  def change
	add_column :arguments, :any_footnotes, :boolean
  end
end
