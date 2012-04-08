class AddFirstargtoDebates < ActiveRecord::Migration
  def change
    add_column :debates, :firstarg, :text
  end
end
