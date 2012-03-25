class AddNoJudgeToDebates < ActiveRecord::Migration
  def change
    add_column :debates, :no_judge, :integer
  end
end
