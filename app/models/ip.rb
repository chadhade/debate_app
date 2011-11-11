class Ip < ActiveRecord::Base
  # associations for viewings
  has_many :viewings, :as => :viewer
  
  validates :IP_address, :uniqueness => true
end
