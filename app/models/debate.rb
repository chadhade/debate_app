class Debate < ActiveRecord::Base
  has_many :debater_debates
  has_many :debaters, :through => :debater_debates
  has_many :arguments
end
