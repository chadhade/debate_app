class Debater < ActiveRecord::Base
  has_many :debater_debates
  has_many :debates, :through => :debater_debates
  has_many :arguments
end
