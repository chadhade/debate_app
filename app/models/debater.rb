class Debater < ActiveRecord::Base
  # associations for viewings
  has_many :viewings, :as => :viewer
  
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :omniauthable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me
  acts_as_voter
  
  # associations for debate participation
  has_many :debations
  has_many :debates, :through => :debations
  
  # associations for debate tracking
  has_many :trackings
  has_many :tracking_debates, :class_name => "Debate", :through => :trackings  
  
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
  
    
  def creator?(debate)
    debate.creator == self
  end
  
  def current_turn?(debate)
    debate.current_turn == self
  end

  def self.find_for_facebook_oauth(access_token, signed_in_resource=nil)
    data = access_token.extra.raw_info
    if debater = Debater.find_by_email(data.email)
      debater
    else # Create a debater with a stub password. 
      Debater.create!(:email => data.email, :password => Devise.friendly_token[0,20], :validate => false) 
    end
  end
  
  def self.find_for_twitter_oauth(access_token, signed_in_resource=nil)
    data = access_token.extra.raw_info
    if debater = Debater.find_by_email(data.email)
      debater
    else # Create a debater with a stub password. 
      Debater.create!(:email => "#{data.screen_name}@twitter.com", :password => Devise.friendly_token[0,20], :validate => false) 
    end
  end

  def following?(followed)
    relationships.find_by_followed_id(followed)
  end
  
  def follow!(followed)
    relationships.create!(:followed_id => followed.id)
  end
  
  def unfollow!(followed)
    relationships.find_by_followed_id(followed).destroy
  end
  
  def is_blocking?(blocked)
    blockings.find_by_blocked_id(blocked)
  end
  
  def block!(followed)
    blockings.create!(:blocked_id => followed.id)
  end
  
  def unblock!(followed)
    blockings.find_by_blocked_id(followed).destroy
  end

  def teammates
    Relationship.get_teammates(self)
  end
  
  
end
