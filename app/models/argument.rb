class Argument < ActiveRecord::Base
  acts_as_voteable
  
  belongs_to :debater
  belongs_to :debate
  
  def votes_for_by(debater)
    Vote.where(:voteable_id => self.id, :voteable_type => self.class.name, :vote => true, :voter_type => debater.class.name, :voter_id => debater.id).count
  end
  
  def votes_against_by(debater)
    Vote.where(:voteable_id => self.id, :voteable_type => self.class.name, :vote => false, :voter_type => debater.class.name, :voter_id => debater.id).count
  end
  
end

