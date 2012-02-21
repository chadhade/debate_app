class AddJoinerIdToDebates < ActiveRecord::Migration
  def change
    add_column :debates, :joiner_id, :integer
  end
end
