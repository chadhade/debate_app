class Debate < ActiveRecord::Base
  has_many :debations
  has_many :debaters, :through => :debations
  has_many :arguments
  
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
  
end
