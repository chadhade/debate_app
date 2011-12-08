class AddCreatorToViewings < ActiveRecord::Migration
  def change
    add_column :viewings, :creator, :boolean
  end
end
