class AddViewersCountToDebates < ActiveRecord::Migration

  def self.up  
    add_column :debates, :viewings_count, :integer, :default => 0  

    Debate.reset_column_information  
    Debate.find_each do |d|  
      Debate.reset_counters d.id :viewings  
    end  
  end  

  def self.down  
    remove_column :debates, :viewings_count  
  end

end
