class Debate < ActiveRecord::Base
  # associations for viewings
  has_many :viewings
  
  # associations for debate participation
  has_many :debations
  has_many :debaters, :through => :debations
  
  # associations for debate tracking
  has_many :trackings
  has_many :debaters_tracking, :class_name => "Debater", :through => :trackings  
  
  # associations for arguments
  has_many :arguments
  
  # associations for footnotes
  has_many :footnotes, :through => :arguments
  
  def creator
    @creator = Debater.find_by_id(self.arguments.first.debater_id)
  end  

  def creator?(debater)
    self.creator == debater
  end
  
  def last_debater
	Debater.find_by_id(self.arguments.last.debater_id)
  end
  
  # assumes toggling between two debaters
  # this may need to be rewritten
  def current_turn
    if self.arguments.last.Repeat_Turn == true 
		self.last_debater
	else
		self.arguments.size % 2 == 0 ? self.creator : self.debaters[1]
	end
  end
  
  def current_turn?(debater)
    self.current_turn == debater
  end
  
  def topic
    @topic = self.arguments.first.content
  end
  
  def self.search(search)
	if search
      @debates = Array.new; all.each {|debate| @debates << debate if debate.topic.match(/#{search}/)}
	  @debates
    else
      find(:all)
    end    
  end
  
  def self.matching_debates(topic_position)
    self.find(:all, :limit => 2)
  end
end
