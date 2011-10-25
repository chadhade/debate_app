class DebaterDebate < ActiveRecord::Base
  has_many :debaters
  has_many :debates
end
