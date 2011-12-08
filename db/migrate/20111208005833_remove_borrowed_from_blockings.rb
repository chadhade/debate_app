class RemoveBorrowedFromBlockings < ActiveRecord::Migration
  def change
    remove_column :blockings, :borrowed?
  end
end
