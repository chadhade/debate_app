class Judging < ActiveRecord::Base
  belongs_to :debater
  belongs_to :debate
end
