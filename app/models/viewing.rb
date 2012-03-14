class Viewing < ActiveRecord::Base
  belongs_to :debate
  belongs_to :debater
  belongs_to :IP, :polymorphic => true
end
