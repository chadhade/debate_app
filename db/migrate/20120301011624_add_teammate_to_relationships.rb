class AddTeammateToRelationships < ActiveRecord::Migration
  def change
    add_column :relationships, :teammate, :boolean
  end
end
