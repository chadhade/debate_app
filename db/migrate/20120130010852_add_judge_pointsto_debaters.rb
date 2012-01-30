class AddJudgePointstoDebaters < ActiveRecord::Migration
  def change
    add_column :debaters, :judge_points, :integer, :default => 0
  end
end
