class Argument < ActiveRecord::Base
  acts_as_voteable
  
  belongs_to :debater
  belongs_to :debate
  
  has_many :footnotes, :dependent => :destroy
  
  validates_length_of :content, :within => 0..1000
  validates_length_of :image_url, :within => 0..150
  
  def votes_for_by(debater_id)
    Vote.where(:voteable_id => self.id, :vote => true, :voter_id => debater_id).count
  end
  
  def votes_against_by(debater_id)
    Vote.where(:voteable_id => self.id, :vote => false,:voter_id => debater_id).count
  end
  
  def votes_by(debater_id)
    Vote.where(:voteable_id => self.id, :voter_id => debater_id).count
  end
  
  def votes_for_except(debater_id)
    Vote.where("voteable_id = ? AND voteable_type = ? AND vote = ? AND voter_id != ?", self.id, self.class.name, true, debater_id).count
  end
  
  def votes_against_except(debater_id)
    Vote.where("voteable_id = ? AND voteable_type = ? AND vote = ? AND voter_id != ?", self.id, self.class.name, false, debater_id).count
  end
  
  def has_footnote?
    content = self.content
    
    if content.index(/\(\((.+)\)\)/) # check for footnoote
        #Make sure there isn't a footnote inside of a footnote -- Can make this search more efficient?
        searchstart = 0
        searchend = 1
        alarm = false
        alarm2 = false
        
        if (content.scan((/\(\((.+)\)\)/)).to_s.length + 4)== content.length #Argument cannot consist of just a footnote
          return false
        end
        
        until ((searchend == content.length) or (alarm2 == true)) do
          if (content[searchstart..searchend]) == "(("
            alarm == true ? alarm2 = true : alarm = true
          end
          if ((content[searchstart..searchend])) == "))"
            alarm == true ? alarm = false : nil
          end
          searchstart = searchstart + 1
          searchend = searchend + 1
        end
        
        if (alarm2 == true)
          return false
        else
          return true
        end
    else
      return false
    end
  end

  def save_footnote(thedebate)
	  content = self.content.gsub("\"", "\'") # Replace double quotes with single quotes
  	endposition = -2
  	content_stripped = ""
  	content_html = content

  	#Find the position of the first footnote
  	startposition = content.index(/\(\((.+)\)\)/)

  	#Save the footnote and its position. Then find the position of the next footnote.
  	until startposition.nil? do
  		content_stripped = content_stripped + content[endposition + 2..startposition - 1] #Produce a version without footnotes

  		endposition = content.index(/\)\)/, startposition - 1)
  		@footnote = content[startposition + 2..endposition - 1]
  		footcount = thedebate.footnotes.count + 1
  		footnotes.create!(:content => @footnote, :position => startposition, :foot_count => footcount)
  		oldstart = startposition
  		startposition = content.index(/\(\((.+)\)\)/, endposition)

  		#Produce a version with footnotes turned into html
      #content_html = content_html.sub(/\(\(#{@footnote}\)\)/,"<a href=\"#\" title=\"#{@footnote}\" class=\"footnote\"> <span>#{footcount}</span> </a>")
  		content_html = content_html + "a"
  		content_html.chop!
  		content_html["((" + @footnote + "))"] = "<a href=\"#\" title=\"#{@footnote}\" class=\"footnote\"> <span>#{footcount}</span> </a>"
  		#content_html.slice! "((" + @footnote + "))"
  		#content_html.insert oldstart, "<a href=\"#\" title=\"#{@footnote}\" class=\"footnote\"> <span>#{footcount}</span> </a>"
    end
	
	 self.update_attributes(:content => content_stripped, :any_footnotes => true, :content_foot => content_html)
	
  end
  
  def show_footnote
	  self.content_foot.html_safe
  end
end

