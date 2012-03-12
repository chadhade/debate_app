class Debate < ActiveRecord::Base
  # associations for matching and judging
  has_many :judgings
  has_many :topic_positions
  
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
  
  def status
    if self.end_time.nil?
      return @status = {:status_code => 0, :status_value => "Waiting for Debater and Judge"} if !self.joined and !self.judge
      return @status = {:status_code => 1, :status_value => "Two Debaters on Board! Waiting for Judge"} if self.joined and !self.judge
      return @status = {:status_code => 2, :status_value => "We've got a Debater and a Judge! Waiting for Second Debater"} if !self.joined and self.judge
      return @status = {:status_code => 3, :status_value => "Ongoing Debate!"} if self.joined and self.judge and self.end_time.nil?
    else
      return @status = {:status_code => 4, :status_value => "Waiting for Judging Results!"} if Time.now <= self.end_time + $judgetime and self.judge_entry.winner_id.nil?
      return @status = {:status_code => 5, :status_value => "Completed Debate"} if !self.judge_entry.winner_id.nil?
      return @status = {:status_code => 6, :status_value => "Debate Over, But No Judging Results Submitted"} if self.judge_entry.winner_id.nil?
    end
    @status
  end
  
  def joined?
    self.arguments.size >= 2
  end
  
  def judger
    #self.judge_entry.debater if !self.judge_entry.nil?
    judger = Debater.find_by_id(self.judge_id) unless !self.judge
  end
  
  def creator
    #@creator = Debater.find_by_id(self.arguments.first(:order => "created_at ASC").debater_id)
    creator = Debater.find_by_id(self.creator_id)
  end
  
  def currently_viewing(who)
    case who
    when "joiner"
      self.viewings.where("viewer_type = ? and viewer_id = ?", "Debater", self.joiner_id).first(:order => "created_at ASC").currently_viewing if self.joined
    when "creator"
      self.viewings.where("viewer_type = ? and viewer_id = ?", "Debater", self.creator_id).first(:order => "created_at ASC").currently_viewing
    when "judge"
      self.viewings.where("viewer_type = ? and viewer_id = ?", "Debater", self.judge_id).first(:order => "created_at ASC").currently_viewing if self.judge
    else
      nil
    end
  end  
  
  def joiner
    #@joiner = Debater.find_by_id(self.arguments.all(:order => "created_at ASC").second.debater_id) unless self.arguments.all(:order => "created_at ASC").second.nil?
    joiner = Debater.find_by_id(self.joiner_id) unless !self.joined
  end
  
  def judge_entry
    self.judgings.first(:order => "created_at ASC")
  end
  
  #def judge_id
  #end
  
  def creator?(debater)
    self.creator == debater
  end

  def joiner?(debater)
    self.joiner == debater
  end
  
  def participant?(debater)
    self.creator == debater || self.joiner == debater || self.judge_id == debater.id
  end
  
  def last_debater
	  Debater.find_by_id(self.arguments.last(:order => "created_at ASC").debater_id)
  end
  
  # assumes toggling between two debaters
  # this may need to be rewritten
  def current_turn
    if self.end_time # Check if Debate has ended
      return nil 
    end
    if self.arguments.last(:order => "created_at ASC").Repeat_Turn == true 
		  self.last_debater
	  else
		  self.arguments.size % 2 == 0 ? self.creator : self.debaters[1]
	  end
  end
  
  def current_turn?(debater)
    self.current_turn == debater
  end
  
  def topic
    @topic = self.arguments.first(:order => "created_at ASC").content
  end
  
  def tp
    self.topic_positions.first(:order => "created_at ASC")
  end
  
  def self.search(search)
	  if search
      @debates = Array.new; all.each {|debate| @debates << debate if (!debate.tp.nil? and debate.tp.topic.match(/#{search}/))}
	    @debates
    else
      find(:all)
    end    
  end
  
  def self.matching_debates(current_tp, max1, max2)
    @matching_debates = Array.new
    @viewing_by_creator = Viewing.where("currently_viewing = ? AND creator = ?", true, true).map{|v| v.debate_id}
    self.where(:id => @viewing_by_creator, :joined => false).each do |debate|
      unless debate.tp.nil?
        topic = debate.tp.topic.upcase
        position = debate.tp.position
        words = topic.split(/\s/)
        current_words = current_tp.topic.upcase.split(/\s/)
        pronouns = self.load_pronouns
        
        current_tp.position != position ? position_match = true : position_match = false
          
          match = false
          # set match to true if even one word matches and append debate to array
          current_words.each do |current_word|
            if current_word.length >= 3
              words.each do |word|
                # File.open("listener_log", 'a+') {|f| f.write("#{word}--------") }
                match = true if current_word.length >= 4 and word.length >= 4 and current_word[/..../] == word[/..../] and !pronouns.include?(current_word)
                match = true if current_word.length >= 3 and word.length >= 3 and current_word == word and !pronouns.include?(current_word)
              end
            end
          end
          debate.position_match = position_match
          @matching_debates << debate if match == true
      end
    end
    
    #Sort the matches so that opposing positions appear at the topic
    @matching_debates = @matching_debates.sort_by {|a| a.position_match ? 0 : 1}
      
    @viewing_by_creator_minus_matching = @viewing_by_creator - @matching_debates.map{|v| v.id}
    @suggested_debates = self.where(:id => @viewing_by_creator_minus_matching, :joined => false).order("judge DESC", "created_at ASC").first(max2)
    
    # return the array
    @matching = {:matching_debates => @matching_debates, :suggested_debates => @suggested_debates}
  end
  
  def position_match
    @position_match
  end
  
  def position_match=(new_match)
    @position_match = new_match
  end
  
  def self.judging_priority(max)
    joined_no_judge = self.where(:joined => true, :judge => false).order("joined_at ASC")
    joined_no_judge_cv = Array.new
    joined_no_judge.each do |debate|
      if debate.currently_viewing("creator") and debate.currently_viewing("joiner")
        joined_no_judge_cv << debate
        max -= 1
        return joined_no_judge_cv if max == 0
      end
    end
    
    #{:joined_no_judge => @joined_no_judge_cv}
    return joined_no_judge_cv 
    
    #this way of pulling the appropriate debates was very inefficient
    # @viewing_by_creator = Viewing.where("currently_viewing = ? AND creator = ?", true, true).map{|v| v.debate_id}
    # @viewing_by_joiner = Viewing.where("currently_viewing = ? AND joiner = ?", true, true).map{|v| v.debate_id}
    # @viewing_by_both = @viewing_by_creator & @viewing_by_joiner
    # @joined_no_judge = self.where(:id => @viewing_by_both, :joined => true, :judge => false).order("joined_at ASC")
    
    #stuff for when we allowed judge to join unjoined debate
    # @unjoined_no_judge = self.where(:id => @viewing_by_creator, :joined => false, :judge => false).order("created_at ASC")
    # {:joined_no_judge => @joined_no_judge, :unjoined_no_judge => @unjoined_no_judge}
    
    #this was of pulling the appropriate debates was very inefficient
    # {:joined_no_judge => @joined_no_judge}
  end
  
  def self.load_pronouns
    @pronouns = ["all", 
      "another", 
      "any", 
      "anybody", 
      "anyone", 
      "anything", 
      "both", 
      "each", 
      "each other", 
      "either", 
      "everybody", 
      "everyone", 
      "everything", 
      "few", 
      "he", 
      "her", 
      "hers", 
      "herself", 
      "him", 
      "himself", 
      "his", 
      "I", 
      "it", 
      "its", 
      "itself", 
      "little", 
      "many", 
      "me", 
      "mine", 
      "more", 
      "most", 
      "much", 
      "my", 
      "myself", 
      "neither", 
      "no one", 
      "nobody", 
      "none", 
      "nothing", 
      "one", 
      "one another", 
      "other", 
      "others", 
      "our", 
      "ours", 
      "ourselves", 
      "several", 
      "she", 
      "some", 
      "somebody", 
      "someone", 
      "something", 
      "that", 
      "their", 
      "theirs", 
      "them", 
      "themselves", 
      "these", 
      "they", 
      "this", 
      "those", 
      "us", 
      "we", 
      "what", 
      "whatever", 
      "which", 
      "whichever", 
      "who", 
      "whoever", 
      "whom", 
      "whomever", 
      "whose", 
      "you", 
      "your", 
      "yours", 
      "yourself", 
      "yourselves"]
  end
end
