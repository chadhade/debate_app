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
  
  def creator?(debate)
    debate.creator == self
  end
  
  def current_turn?(debate)
    debate.current_turn == self
  end
end
