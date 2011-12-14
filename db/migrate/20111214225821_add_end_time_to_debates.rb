class AddEndTimeToDebates < ActiveRecord::Migration
  def change
    add_column :debates, :end_time, :datetime
  end
end
