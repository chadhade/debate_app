class EditNoJudgeFromDebates < ActiveRecord::Migration
  def change
    change_column :debates, :no_judge, :integer, :default => 0
  end
end
