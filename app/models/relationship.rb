class Relationship < ActiveRecord::Base
  attr_accessible :followed_id
  
  belongs_to :follower, :class_name => "Debater"
  belongs_to :followed, :class_name => "Debater"
  
  validates :follower_id, :presence => true
  validates :followed_id, :presence => true
  
  scope :get_teammates, lambda { |debater| teammates_with(debater)}

  private
  
    # Return an SQL condition for debaters following and followed by the same debater
    
    def self.teammates_with(debater)
      follower_ids = %(SELECT follower_id FROM relationships WHERE followed_id = :debater_id)
      where ("followed_id IN (#{follower_ids})", {:debater_id => debater})
    end
end
