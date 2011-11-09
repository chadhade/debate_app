class Tracking < ActiveRecord::Base
  belongs_to :tracking_debates, :foreign_key => :debate_id
  belongs_to :debater_tracking, :foreign_key => :debater_id
  
  validates :debater_id, :presence => true, :uniqueness => {:scope => :debate_id}
end
