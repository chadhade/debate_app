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
	
	@startposition = @partialcontent.index(/\(\((.+)\)\)/)
	
	until @startposition.nil? do
		@endposition = @partialcontent.index(/\)\)/, @startposition - 1)
		@footnote = @partialcontent[@startposition + 2..@endposition - 1]
		footnotes.create!(:content => @footnote, :position => @startposition)
		@startposition = @partialcontent.index(/\(\((.+)\)\)/, @endposition)
	end
	
	#Remove the footnote from the argument
	self.update_attributes(:content => @content)
  end
  
  end

