class AddResultsToJudgings < ActiveRecord::Migration
  def change
    add_column :judgings, :winner_id, :integer
    add_column :judgings, :comments, :text
  end
end
