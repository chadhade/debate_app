class Suggested_Topic < ActiveRecord::Base
  #attr_accessible #none
  
  def self.trending(number)
    return Suggested_Topic.find(:all, :limit => number, :order => "rating DESC")
  end
  
end
