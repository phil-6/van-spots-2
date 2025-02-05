class Spot < ApplicationRecord
  has_many :ratings, dependent: :destroy, foreign_key: :spot_id
  belongs_to :user

  def average_rating
    ratings.blank? ? 0 : (ratings.sum(:score).to_f / ratings.count).round(1)
  end

  # validations
  validates_presence_of :name,
                        :user_id,
                        :spot_type,
                        :description,
                        :latitude,
                        :longitude
  validates :spot_type, inclusion: {
    in: %w[free_spot paid_spot campsite mtb_spot climbing_spot kayaking_spot surf_spot bad_spot],
    message: "%{value} is not a valid spot type" }
end
