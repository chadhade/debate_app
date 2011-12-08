class AddJoinedAtToDebates < ActiveRecord::Migration
  def change
    add_column :debates, :joined_at, :datetime
  end
end
