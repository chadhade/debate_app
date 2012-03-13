class AddLastRequestAttoDebaters < ActiveRecord::Migration
  def change
    add_column :debaters, :last_request_at, :datetime
  end
end
