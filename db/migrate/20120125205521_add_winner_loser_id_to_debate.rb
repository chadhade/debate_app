class AddWinnerLoserIdToDebate < ActiveRecord::Migration
  def change
    add_column :debates, :winner_id, :integer
    add_column :debates, :loser_id, :integer
  end
end
