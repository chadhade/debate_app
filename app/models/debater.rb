class Debater < ActiveRecord::Base
  # associations for matching and judging
  has_many :judgings
  has_many :topic_positions
  
  # associations for viewings
  has_many :viewings, :as => :viewer
  
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :rememberable, and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :trackable, :validatable, :omniauthable,
         :confirmable, :lockable, :timeoutable

  validates_length_of :name, :within => 2..15
  validates_uniqueness_of :name
  
  # Virtual attribute for authenticating by either username or email
  attr_accessor :login
  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :name, :password, :password_confirmation, :remember_me, :login
  
  acts_as_voter
  attr_accessible :arg_upvotes, :arg_downvotes, :judge_points
  
  attr_accessible :waiting_for
  
  # associations for debate participation
  has_many :debations
  has_many :debates, :through => :debations
  
  # associations for debate tracking
  #has_many :trackings
  #has_many :tracking_debates, :class_name => "Debate", :through => :trackings  
  
  #associations for arguments
  has_many :arguments
  
  #associations for relationships and blockings
  has_many :relationships, :foreign_key => "follower_id", :dependent => :destroy
  has_many :following, :through => :relationships, :source => :followed
  has_many :reverse_relationships, :foreign_key => "followed_id", :class_name => "Relationship", :dependent => :destroy
  has_many :followers, :through => :reverse_relationships, :source => :follower
  has_many :blockings, :foreign_key => "blocker_id", :dependent => :destroy
  has_many :is_blocking, :through => :blockings, :source => :blocked
  has_many :reverse_blockings, :foreign_key => "blocked_id", :class_name => "Blocking", :dependent => :destroy
  has_many :blockers, :through => :reverse_blockings, :source => :blocker
  
  scope :teammates, lambda { |debater| team_debaters(debater)}
  
  def active?
    self.current_sign_in_at and !self.timedout?(self.last_request_at)
  end
  
  def judge?(debate)
    if !debate.judge
      false
    else
      debate.judge_id == self.id
    end
  end
    
  def creator?(debate)
    debate.creator == self
  end
  
  def joiner?(debate)
    debate.joiner == self  
  end
  
  def current_turn?(debate)
    debate.current_turn == self
  end

  def self.find_for_database_authentication(warden_conditions)
     conditions = warden_conditions.dup
     login = conditions.delete(:login)
     where(conditions).where(["lower(name) = :value OR lower(email) = :value", { :value => login.strip.downcase }]).first
  end
   
  def self.find_for_facebook_oauth(access_token, signed_in_resource=nil)
    data = access_token.extra.raw_info
    debater = Debater.find_by_email(data.email)
    if debater 
      debater
    else # Create a debater with a stub password. 
      debater = Debater.new(:email => data.email, :name => data.name, :confirmed_at => Time.now, :password => Devise.friendly_token[0,20]) 
      debater.confirmed_at = Time.now
      debater
    end
  end
  
  def self.find_for_twitter_oauth(access_token, signed_in_resource=nil)
    data = access_token.extra.raw_info
    debater = Debater.find_by_email(data.screen_name.downcase + "@twitter.com")
    if debater
      debater
    else # Create a debater with a stub password. 
      debater = Debater.new(:email => "#{data.screen_name}@twitter.com", :name => data.screen_name, :password => Devise.friendly_token[0,20]) 
      debater.confirmed_at = Time.now
      debater
    end
  end

  def following?(followed)
    relationships.find_by_followed_id(followed)
  end
  
  def is_blocking?(blocked)
    blockings.find_by_blocked_id(blocked)
  end
  
  def teammates?(followed)
    !Relationship.get_teammates_id(self).find_by_followed_id(followed.id).nil?
  end
  
  def follow!(followed)
    relationships.create!(:followed_id => followed.id)
  end
  
  def unfollow!(followed)
    relationships.find_by_followed_id(followed).destroy
  end
  
  def block!(followed)
    blockings.create!(:blocked_id => followed.id)
  end
  
  def unblock!(followed)
    blockings.find_by_blocked_id(followed).destroy
  end

  def teammates
    ids = Relationship.get_teammates_id(self)
  end
    
  def rank
    wins = Judging.where("winner_id = ?", self.id).count
    losses = Judging.where("loser_id = ?", self.id).count
    (wins == 0) ? rank = 0 : rank = wins.to_f/(wins + losses)
  end
  
  def mini_name
    self.name[0..9]
  end
  
  private
  
    def self.team_debaters(debater)
      team_ids = Relationship.get_teammates_id(debater).map{|v| v.followed_id}
      
      if !team_ids.empty?
        
        #where("id IN (#{team_ids})", {:debater_id => debater})
        where(:id => team_ids)
      else
        where("id IN (3.14)", {:debater_id => debater}) #Fix for heroku.  This will always return an empty set
      end
    end
  
  
end
