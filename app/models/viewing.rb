class Viewing < ActiveRecord::Base
  belongs_to :debate
  belongs_to :debater, :polymorphic => true
  belongs_to :IP, :polymorphic => true
end
