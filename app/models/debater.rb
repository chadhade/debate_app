class Debater < ActiveRecord::Base
  acts_as_voter
  
  # associations for debate participation
  has_many :debations
  has_many :debates, :through => :debations
  
  # associations for debate tracking
  has_many :trackings
  has_many :tracking_debates, :class_name => "Debate", :through => :trackings  
  
  #associations for arguments
  has_many :arguments
  
  def creator?(debate)
    debate.creator == self
  end
  
  def current_turn?(debate)
    debate.current_turn == self
  end
end
