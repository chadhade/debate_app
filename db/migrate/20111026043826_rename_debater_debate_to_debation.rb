class RenameDebaterDebateToDebation < ActiveRecord::Migration
  def up
    rename_table :debater_debates, :debations
  end

  def down
    rename_table :debations, :debater_debates
  end
end
