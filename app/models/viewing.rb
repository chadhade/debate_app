class Viewing < ActiveRecord::Base
  belongs_to :debate, :counter_cache => true
  belongs_to :debater, :foreign_key => "viewer_id"
  belongs_to :IP, :polymorphic => true
end
