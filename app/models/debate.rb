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
  
  # assumes toggling between two debaters
  # this may need to be rewritten
  def current_turn
    self.arguments.size % 2 == 0 ? self.creator : self.debaters[1]
  end
  
  def current_turn?(debater)
    self.current_turn == debater
  end
  
  def topic
    @topic = self.arguments.first.content
  end
end
