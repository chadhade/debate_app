class Argument < ActiveRecord::Base
  acts_as_votable
  
  belongs_to :debater
  belongs_to :debate
end
