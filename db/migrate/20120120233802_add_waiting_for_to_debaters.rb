class AddWaitingForToDebaters < ActiveRecord::Migration
  def change
    add_column :debaters, :waiting_for, :integer
  end
end
