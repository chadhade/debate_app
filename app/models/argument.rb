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
	@content = self.content
	@partialcontent = @content
	#Find the position of the first footnote
	@startposition = @partialcontent.index(/\(\((.+)\)\)/)
	
	until @startposition.nil? do
		@endposition = @partialcontent.index(/\)\)/, @startposition - 1)
		#Save the footnote and its position. Then find the position of the next footnote.
		@footnote = @partialcontent[@startposition + 2..@endposition - 1]
		footnotes.create!(:content => @footnote, :position => @startposition)
		@startposition = @partialcontent.index(/\(\((.+)\)\)/, @endposition)
	end
	
	#Remove the footnote from the argument
	@content = @content.gsub(/\(\((.+)\)\)/,"")
	self.update_attributes(:content => @content, :any_footnotes => true)
  end
  
  def show_footnote
	@content = self.content
	placeholder = 0
	self.footnotes.each do |footnote|
		@footnote_as_link = "<a href=\"#\" title=#{footnote.content} class=\"footnote\"> <span>#{footnote.id}</span> </a>"
		@content.insert(footnote.position + placeholder, @footnote_as_link)
		placeholder = placeholder + footnote.content.length
	end
	@content.html_safe
  end
  
  end

