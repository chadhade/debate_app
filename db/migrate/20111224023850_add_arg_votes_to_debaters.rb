class AddArgVotesToDebaters < ActiveRecord::Migration
  def change
    add_column :debaters, :arg_upvotes, :integer, :default => 0
    add_column :debaters, :arg_downvotes, :integer, :default => 0
  end
end
