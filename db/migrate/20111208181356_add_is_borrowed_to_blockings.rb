class AddIsBorrowedToBlockings < ActiveRecord::Migration
  def change
    add_column :blockings, :is_borrowed, :boolean
  end
end
