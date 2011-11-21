class Footnote < ActiveRecord::Base
	attr_accessible :content, :position
	
	belongs_to :argument
end
