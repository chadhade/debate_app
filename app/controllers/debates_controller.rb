class DebatesController < ApplicationController

  def new
  end
  
  def create
    @debate = Debate.new
	@debate.save
	current_debater.debater_debates.create(:debate_id => @debate.id)
  end
  
  def show
  end
  
  def index
  end

end
