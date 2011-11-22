class Footnote < ActiveRecord::Base
	attr_accessible :content, :position, :foot_count
	
	belongs_to :argument
end
