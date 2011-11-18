class AddPositiontoFootnotes < ActiveRecord::Migration
  def change
    add_column :footnotes, :position, :integer
  end
end
