class AddJudgeToDebates < ActiveRecord::Migration
  def change
    add_column :debates, :judge, :boolean
  end
end
