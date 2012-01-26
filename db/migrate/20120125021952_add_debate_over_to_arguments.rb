class AddDebateOverToArguments < ActiveRecord::Migration
  def change
    add_column :arguments, :debate_over, :boolean
  end
end
