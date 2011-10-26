class Debater < ActiveRecord::Base
  has_many :debations
  has_many :debates, :through => :debations
  has_many :arguments
end
