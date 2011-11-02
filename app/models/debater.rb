class Debater < ActiveRecord::Base
  acts_as_voter
  
  has_many :debations
  has_many :debates, :through => :debations
  has_many :arguments
  
  def creator?(debate)
    debate.creator == self
  end
  
  def current_turn?(debate)
    debate.current_turn == self
  end
end
