class Micropost < ApplicationRecord
  belongs_to :user # references users tabled
  default_scope -> { order(created_at: :desc) }
  mount_uploader :picture, PictureUploader # CarrierWave gem associates image with micropost model
  validates :user_id, presence: true
  validates :content, presence: true, length: { maximum: 140 }
  validates :picture_size

  private
  	def picture_size
  		if picture.size > 5.megabytes
  			errors.add(:picture, "should be less than 5MB")
  		end
  	end
end
