class AddDeviseModulestoDebaters < ActiveRecord::Migration
  def up
    change_table(:debaters) do |t|
      t.confirmable
      t.lockable :lock_strategy => :failed_attempts, :unlock_strategy => :both
    end
    
    add_index :debaters, :confirmation_token,   :unique => true
    add_index :debaters, :unlock_token,         :unique => true
  end

  def down
    change_table(:debaters) do |t|
      t.remove :confirmable
      t.remove :lockable
    end
  end

end
