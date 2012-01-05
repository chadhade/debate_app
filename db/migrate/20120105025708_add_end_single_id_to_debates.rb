class AddEndSingleIdToDebates < ActiveRecord::Migration
  def change
    add_column :debates, :end_single_id, :integer
  end
end
