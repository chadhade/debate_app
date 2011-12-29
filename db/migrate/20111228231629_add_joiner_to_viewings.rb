class AddJoinerToViewings < ActiveRecord::Migration
  def change
    add_column :viewings, :joiner, :boolean
  end
end
