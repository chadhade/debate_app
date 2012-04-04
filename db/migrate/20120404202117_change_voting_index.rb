class ChangeVotingIndex < ActiveRecord::Migration
  def change
    remove_index :votes, :column => :voteable_id
    add_index :votes, [:voteable_id, :voteable_type]
  end
end
