class DebatesController < ApplicationController

  def new
    # creating a new debate is the same as creating the first argument
	@argument = Argument.new
  end
  
  def create
	# create a new debate linked to debater
	@debate = Debate.new
	@debate.save
	current_debater.debations.create(:debate_id => @debate.id)
	
	# create a new argument object
	@content_of_post = params[:argument][:content]
	@argument = current_debater.arguments.create(:content => @content_of_post, :debate_id => @debate.id)
	
	redirect_to @debate
  end
  
  def join
    # link debater to debate
	# current_debater.debations.create(:debate_id => params[:id])
	
	# create a new argument object
	# @content_of_post = params[:argument][:content]
	# @argument = current_debater.arguments.create(:content => @content_of_post, :debate_id => @debate.id)
	
	# redirect_to @debate
  end
  
  def show
    # pull all arguments from that debate and pass debate object
	@debate = Debate.find(params[:id])
	@arguments = @debate.arguments
  end
  
  def index
  end

end
