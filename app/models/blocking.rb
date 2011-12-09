class Blocking < ActiveRecord::Base
  attr_accessible :blocked_id, :borrowed?
  
  belongs_to :blocker, :class_name => "Debater"
  belongs_to :blocked, :class_name => "Debater"
  
  validates :blocker_id, :presence => true
  validates :blocked_id, :presence => true

end
