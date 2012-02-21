class AddStarterIdToDebates < ActiveRecord::Migration
  def change
    add_column :debates, :creator_id, :integer
  end
end
