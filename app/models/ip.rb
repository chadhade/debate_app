class Ip < ActiveRecord::Base
  # associations for viewings
  has_many :viewings, :as => :viewer
end
