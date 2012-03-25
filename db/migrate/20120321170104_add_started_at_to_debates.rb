class AddStartedAtToDebates < ActiveRecord::Migration
  def change
    add_column :debates, :started_at, :datetime
  end
end
