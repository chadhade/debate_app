class AddtimeLefcolumntoarguments < ActiveRecord::Migration
  def up
	add_column :arguments, :time_left, :integer
  end

  def down
  end
end
