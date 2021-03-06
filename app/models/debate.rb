class Debate < ActiveRecord::Base
  # associations for matching and judging
  has_one :judging, :dependent => :destroy
  #has_one :topic_position, :dependent => :destroy
  
  # associations for viewings
  has_many :viewings, :dependent => :destroy
  
  # associations for debate participation
  has_many :debations, :dependent => :destroy
  has_many :debaters, :through => :debations
  
  # associations for debate tracking
  has_many :trackings
  has_many :debaters_tracking, :class_name => "Debater", :through => :trackings  
  
  # associations for arguments
  has_many :arguments, :dependent => :destroy
  
  # associations for footnotes
  has_many :footnotes, :through => :arguments
  
  # Websolr/Sunspot indexing for search
  searchable do
    text :topic, :boost => 5.0
    text :firstarg
    
    boolean :position
    boolean :joined
    integer :id
    integer :creator_id
    time    :started_at
    time    :created_at
  end
    
  
  def status
    if self.end_time.nil?
      return @status = {:status_code => 0, :status_value => "Waiting for Debater and Judge"} if !self.joined and !self.judge and self.no_judge == 0
      return @status = {:status_code => 0.5, :status_value => "Waiting for Debater"} if !self.joined and !self.judge and self.no_judge == 1
      return @status = {:status_code => 1, :status_value => "Two Debaters on Board! Waiting for Judge"} if self.joined and !self.judge and self.no_judge != 3
      return @status = {:status_code => 2, :status_value => "We've got a Debater and a Judge! Waiting for Second Debater"} if !self.joined and self.judge
      return @status = {:status_code => 3, :status_value => "Ongoing Debate!"} if self.joined and (self.judge or self.no_judge == 3)
    else
      return @status = {:status_code => 7, :status_value => "Completed Debate without Judge."} if self.no_judge == 3
      return @status = {:status_code => 4, :status_value => "Waiting for Judging Results!"} if Time.now <= self.end_time + $judgetime and self.judge_entry.winner_id.nil?
      return @status = {:status_code => 5, :status_value => "Completed Debate"} if !self.judge_entry.winner_id.nil?
      return @status = {:status_code => 6, :status_value => "Debate Over, But No Judging Results Submitted"} #if self.judge_entry.winner_id.nil?
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
  
  
  def joiner
    #@joiner = Debater.find_by_id(self.arguments.all(:order => "created_at ASC").second.debater_id) unless self.arguments.all(:order => "created_at ASC").second.nil?
    joiner = Debater.find_by_id(self.joiner_id) unless !self.joined
  end
  
  def judge_entry
    self.judging
  end
  
  def creator?(debater)
    self.creator_id == debater.id
  end

  def joiner?(debater)
    self.joiner_id == debater.id
  end
  
  def judger?(debater)
    self.judge_id == debater.id
  end
  
  def participant?(debater)
    ((self.creator_id == debater.id) or (self.joiner_id == debater.id) or (self.judge_id == debater.id))
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
    arguments = self.arguments
    if arguments.last(:order => "created_at ASC").Repeat_Turn == true 
		  self.last_debater
	  else
		  arguments.size % 2 == 0 ? self.creator : self.joiner
	  end
  end
  
  def current_turn?(debater)
    self.current_turn == debater
  end
  
  #def topic
    #@topic = self.arguments.first(:order => "created_at ASC").content
  #end
  
  def tp
    #self.topic_position
    self
  end
  
  def self.search(search, max) #No longer used. Replaced by solr_search (debates index action)
	  limit = Time.now - 15.days
	  if search
      @debates = Array.new; 
      #Debate.where("started_at > ?", limit).order("started_at DESC").first(max).each {|debate| @debates << debate if (!debate.tp.nil? and debate.tp.topic.downcase.match(/#{search.downcase}/))}
	    Debate.where("started_at > ?", limit).order("started_at DESC").first(max).each {|debate| @debates << debate if (debate.topic.downcase.match(/#{search.downcase}/))}
	    @debates
    else
      Debate.where("started_at > ?", limit).order("started_at DESC").first(max)
    end    
  end
  
  def self.matching_debates(current_tp, max1, max2, blocked)
  
    viewing_by_creator_ids = Viewing.where("creator = ? AND viewer_id not in (?)", true, blocked).map{|v| v.debate_id}
    
    if viewing_by_creator_ids.any?
      @debates =
      Debate.solr_search(:include => [:debaters]) do
        with(:id, viewing_by_creator_ids)
        with(:joined, false)
        fulltext(current_tp.topic) do
          boost(1.5) { with(:position, !current_tp.position) }
          phrase_fields :topic => 2.0
          phrase_fields :firstarg => 2.0
        end
      
        paginate :page => 1, :per_page => max1
        order_by(:score, :desc)
        order_by(:created_at, :asc)
      end
      searchresults = @debates.results
      #Remove Debates where the creator is no longer active
      searchresults.delete_if {|d| !d.creator.active? }
      searchresults.each {|d| if !d.debaters[0].active?; d.debaters[0].clear_session; searchresults.delete(d); end }
      
      result_ids = searchresults.map(&:id) unless searchresults.nil?
      result_ids = Array.new if result_ids.nil?
      suggested_ids = viewing_by_creator_ids - result_ids
    
      suggested_debates = self.where(:id => suggested_ids, :joined => false).order("created_at ASC").includes(:debaters).first(max2)
      #Remove Debates where the creator is no longer active
      suggested_debates.each {|d| if !d.debaters[0].active?; d.debaters[0].clear_session; suggested_debates.delete(d); end }
    else
      searchresults = Array.new
      suggested_debates = Array.new
    end
      
    # return the array
    @matching = {:matching_debates => searchresults, :suggested_debates => suggested_debates}
  end
  
  def self.suggested_debates(max, blocked)
    viewing_by_creator_ids = Viewing.where("creator = ? AND viewer_id not in (?)", true, blocked).map{|v| v.debate_id}
    
    if viewing_by_creator_ids.any?
      suggested_ids = viewing_by_creator_ids
      suggested_debates = self.where(:id => suggested_ids, :joined => false).order("created_at ASC").includes(:debaters).first(max + 5)
      
      #Remove Debates where the creator is no longer active
      suggested_debates.each {|d| if !d.debaters[0].active?; d.debaters[0].clear_session; suggested_debates.delete(d); end }
      
      suggested_debates = suggested_debates.first(max)
    else
      suggested_debates = Array.new
    end
      
    # return the array
    @matching = {:matching_debates => Array.new, :suggested_debates => suggested_debates}
  end
  
 # This is no longer in use  #######################
    def self.matching_debates_old(current_tp, max1, max2, blocked) 
      @matching_debates = Array.new
      @suggested_debates = Array.new
    
      viewing_by_creator_ids = Viewing.where("creator = ? AND viewer_id not in (?)", true, blocked).map{|v| v.debate_id}
    
      @debates = self.where(:id => viewing_by_creator_ids, :joined => false).order("created_at ASC").includes(:debaters)
    
      @debates.each do |debate|
      
        creator = debate.debaters.first
        unless !creator.active?
          topic = debate.tp.topic.upcase
          topic = topic + ' ' + debate.firstarg.upcase unless debate.firstarg.nil? #temporary
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
                  if !match
                    match = true if current_word.length >= 3 and word.length >= 3 and current_word == word and !pronouns.include?(current_word)
                  end
                end
              end
            end
            debate.position_match = position_match
            match ? @matching_debates << debate : @suggested_debates << debate
        end
      
        #If the debate's creator is inactive, clear his session
        #Temporary creator.clear_session if !creator.active?
      end
    
      #Sort the matches so that opposing positions appear at the topic
      @matching_debates = @matching_debates.sort_by {|a| a.position_match ? 0 : 1}
      @matching_debates = @matching_debates.first(max1)  
      @suggested_debates = @suggested_debates.first(max2)
    
      # return the array
      @matching = {:matching_debates => @matching_debates, :suggested_debates => @suggested_debates}
    end
############################################  
  
  
  def position_match
    @position_match
  end
  
  def position_match=(new_match)
    @position_match = new_match
  end
  
  def self.judging_priority(max, blocked)
    max == 1 ? judge_order = "joined_at DESC" : judge_order = "joined_at ASC"
    joined_no_judge = self.where("joined = ? AND judge = ? AND creator_id not in (?)", true, false, blocked)
    joined_no_judge = joined_no_judge.where("no_judge != ?", 3).order(judge_order) unless joined_no_judge.nil?
    joined_no_judge_cv = Array.new
    joined_no_judge.each do |debate|
      activejoiner = debate.joiner.active?
      activecreator = debate.creator.active?
      if activejoiner and activecreator and debate.viewings.size > 1
        if debate.currently_viewing(debate.creator_id) and debate.currently_viewing(debate.joiner_id)
          joined_no_judge_cv << debate
          max -= 1
          return joined_no_judge_cv if max == 0
        end
      else
        # If the joiner and creator are no longer active, declare the debate as over
        if !(activejoiner or activecreator)
          debate.update_attributes(:end_time => Time.now, :no_judge => 3)
        end
      end
    end
    
    return joined_no_judge_cv 
    
  end
  
  def currently_viewing(debater_id)
    return false if debater_id.nil?
    #self.viewings.where("viewer_id = ?", debater_id).first(:order => "created_at ASC").currently_viewing
    self.viewings.where("viewer_id = ?", debater_id).any?
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
