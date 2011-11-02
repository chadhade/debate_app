class AddtimeLefcolumntoarguments < ActiveRecord::Migration
  def change
	add_column :arguments, :time_left, :integer
  end
end
