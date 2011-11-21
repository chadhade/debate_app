class AddFootCountToFootnotes < ActiveRecord::Migration
  def change
	add_column :footnotes, :foot_count, :integer
  end
end
