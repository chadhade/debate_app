class AddLoserIdToJudgings < ActiveRecord::Migration
  def change
    add_column :judgings, :loser_id, :integer
  end
end
