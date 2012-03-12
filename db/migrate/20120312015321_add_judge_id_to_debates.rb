class AddJudgeIdToDebates < ActiveRecord::Migration
  def change
    add_column :debates, :judge_id, :integer
  end
end
