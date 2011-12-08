class AddJoinedToDebates < ActiveRecord::Migration
  def change
    add_column :debates, :joined, :boolean
  end
end
