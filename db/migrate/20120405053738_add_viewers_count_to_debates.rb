class AddViewersCountToDebates < ActiveRecord::Migration

  def self.up  
    add_column :debates, :viewings_count, :integer, :default => 0  

    Debate.reset_column_information  
    Debate.all.each do |d|  
      d.update_attribute :viewings_count, d.viewings.length  
    end  
  end  

  def self.down  
    remove_column :debates, :viewings_count  
  end

end
