class Album < ActiveRecord::Base
  belongs_to :user

  has_many :images
  belongs_to :cover, class_name: "Image", foreign_key: "cover"
end
