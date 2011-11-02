class AddRepeatTurnToArguments < ActiveRecord::Migration
  def change
    add_column :arguments, :Repeat_Turn, :boolean
  end
end
