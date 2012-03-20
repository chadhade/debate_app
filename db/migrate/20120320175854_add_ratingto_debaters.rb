class AddRatingtoDebaters < ActiveRecord::Migration
  def change
    add_column :debaters, :rating, :integer
  end
end
