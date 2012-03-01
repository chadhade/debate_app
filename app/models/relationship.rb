class Relationship < ActiveRecord::Base
  attr_accessible :followed_id, :teammate
  
  belongs_to :follower, :class_name => "Debater"
  belongs_to :followed, :class_name => "Debater"
  
  validates :follower_id, :presence => true
  validates :followed_id, :presence => true
  
  scope :get_teammates_id, lambda { |debater| teammates_with(debater)}

  private
  
    # Return an SQL condition for debaters following and followed by the same debater
    
    def self.teammates_with(debater)
      #follower_ids = %(SELECT follower_id FROM relationships WHERE followed_id = :debater_id)
      follower_ids = Relationship.where("followed_id = ? AND teammate = ?", debater.id.to_i, true).select("follower_id").map(&:follower_id)
      where("follower_id = :debater_id AND teammate = :teammate_t AND followed_id IN (#{follower_ids})", {:debater_id => debater, :teammate_t => true})
    end
end
