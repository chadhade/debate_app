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

  def save_footnote(thedebate)
	content = self.content
	endposition = -2
	content_stripped = ""
	content_html = content
	
	#Find the position of the first footnote
	startposition = content.index(/\(\((.+)\)\)/)
	
	#Save the footnote and its position. Then find the position of the next footnote.
	until startposition.nil? do
		content_stripped = content_stripped + content[endposition + 2..startposition - 1] #Produce a version without footnotes
		
		endposition = content.index(/\)\)/, startposition - 1)
		@footnote = content[startposition + 2..endposition - 1]
		footcount = thedebate.footnotes.count + 1
		footnotes.create!(:content => @footnote, :position => startposition, :foot_count => footcount)
		startposition = content.index(/\(\((.+)\)\)/, endposition)
	
		#Produce a version with footnotes turned into html
		content_html = content_html.sub(/\(\(#{@footnote}\)\)/,"<a href=\"#footnote#{footcount}\" title=\"#{@footnote}\" class=\"footnote\"> 
		               <span>#{footcount}</span> </a>")
	end
	
	self.update_attributes(:content => content_stripped, :any_footnotes => true, :content_foot => content_html)
	
  end
  
  def show_footnote
	self.content_foot.html_safe
  end
  
  end

