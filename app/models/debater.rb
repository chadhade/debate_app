class Debater < ActiveRecord::Base
  # associations for matching and judging
  has_many :judgings
  has_many :topic_positions
  
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
  
  def judge?(debate)
    debate.judge.debater_id == self.id
  end
  
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
end
