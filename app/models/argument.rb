class Argument < ActiveRecord::Base
  acts_as_voteable
  
  belongs_to :debater
  belongs_to :debate
  
  has_many :footnotes, :dependent => :destroy
  
  def votes_for_by(debater)
    Vote.where(:voteable_id => self.id, :voteable_type => self.class.name, :vote => true, :voter_type => debater.class.name, :voter_id => debater.id).count
  end
  
  def votes_against_by(debater)
    Vote.where(:voteable_id => self.id, :voteable_type => self.class.name, :vote => false, :voter_type => debater.class.name, :voter_id => debater.id).count
  end
  
  def has_footnote?
	self.content.index(/\(\((.+)\)\)/)
  end

  def save_footnote
	content = self.content
	
	#Find the position of the first footnote
	startposition = content.index(/\(\((.+)\)\)/)
	endposition = -2
	content_stripped = ""
	
	#Save the footnote and its position. Then find the position of the next footnote.
	until startposition.nil? do
		#Produce a version without footnotes
		content_stripped = content_stripped + content[endposition + 2..startposition - 1]
		
		endposition = content.index(/\)\)/, startposition - 1)
		@footnote = content[startposition + 2..endposition - 1]
		footnotes.create!(:content => @footnote, :position => startposition)
		startposition = content.index(/\(\((.+)\)\)/, endposition)
	end
	
	self.update_attributes(:content => content_stripped, :any_footnotes => true)
	
  end
  
  def show_footnote
	@content = self.content
	placeholder = 0
	self.footnotes.each do |footnote|
		@footnote_as_link = "<a href=\"#\" title=#{footnote.content} class=\"footnote\"> <span>#{footnote.id}</span> </a>"
		@content.insert(footnote.position + placeholder, @footnote_as_link)
		placeholder = (placeholder + @footnote_as_link.length) - footnote.content.length - 4
		#return placeholder
	end
	@content.html_safe
  end
  
  end

