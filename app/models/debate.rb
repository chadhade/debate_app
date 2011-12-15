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
  
  def joined?
    self.arguments.size >= 2
  end
  
  def judger
    self.judge_entry.debater if !self.judge_entry.nil?
  end
  
  def creator
    @creator = Debater.find_by_id(self.arguments.first.debater_id)
  end  
  
  def judge_entry
    self.judgings.first
  end
  
  def judge_id
    self.judge? == true ? self.judgings.first.debater_id : nil
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
  
  def self.matching_debates(current_tp)
    @matching_debates = Array.new
    @viewing_by_creator = Viewing.where("currently_viewing = ? AND creator = ?", true, true).map{|v| v.debate_id}
    self.where(:id => @viewing_by_creator, :joined => false).each do |debate|
      topic = debate.topic_positions.first.topic
      position = debate.topic_positions.first.position
      words = topic.split(/\s/)
      current_words = current_tp.topic.split(/\s/)
      if current_tp.position != position
        # set match to true if even one word matches and append debate to array
        match = false
        current_words.each do |current_word|
          if current_word.length >= 4
            words.each do |word|
              # File.open("listener_log", 'a+') {|f| f.write("#{word}--------") }
              if current_word == word
                match = true
              end
            end
          end
        end
        @matching_debates << debate if match == true
      end
    end
    # return the array
    @matching_debates
  end
  
  def self.judging_priority()
    @viewing_by_creator = Viewing.where("currently_viewing = ? AND creator = ?", true, true).map{|v| v.debate_id}
    @joined_no_judge = self.where(:id => @viewing_by_creator, :joined => true, :judge => false).order("joined_at ASC")
    @unjoined_no_judge = self.where(:id => @viewing_by_creator, :joined => false, :judge => false).order("created_at ASC")
    {:joined_no_judge => @joined_no_judge, :unjoined_no_judge => @unjoined_no_judge}
  end
end
