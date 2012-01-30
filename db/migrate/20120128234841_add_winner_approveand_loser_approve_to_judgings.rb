class AddWinnerApproveandLoserApproveToJudgings < ActiveRecord::Migration
  def change
    add_column :judgings, :winner_approve, :boolean
    add_column :judgings, :loser_approve, :boolean
  end
end
