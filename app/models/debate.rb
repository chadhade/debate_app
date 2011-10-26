class Debate < ActiveRecord::Base
  has_many :debations
  has_many :debaters, :through => :debations
  has_many :arguments
end
