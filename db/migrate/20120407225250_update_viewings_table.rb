class UpdateViewingsTable < ActiveRecord::Migration
  def change
    remove_index :viewings, :column => [:currently_viewing, :creator]
    remove_column :viewings, :viewer_type
    remove_column :viewings, :currently_viewing
    remove_column :viewings, :updated_at
    remove_column :viewings, :joiner
  end
end
