class Rating < ApplicationRecord
  belongs_to :user
  belongs_to :spot
  validates_presence_of :user_id, :spot_id, :score
end
