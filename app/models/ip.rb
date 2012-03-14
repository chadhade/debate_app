class Ip < ActiveRecord::Base
  # associations for viewings
  has_many :viewings
  
  validates :IP_address, :uniqueness => true
end
