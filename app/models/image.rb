class Image < ActiveRecord::Base
  belongs_to :album
  has_many :thumbnails, dependent: :destroy

  has_attached_file :file, :path => ":class/:attachment/:id/:basename.:extension"
  validates :file, :attachment_presence => true
  validates_attachment_content_type :file, :content_type => /\Aimage\/.*\Z/

  include Rails.application.routes.url_helpers

  def to_jq_upload
    {
      "name" => read_attribute(:file_file_name),
      "size" => read_attribute(:file_file_size),
      "url" => file.url(:original),
      "delete_url" => image_path(self),
      "delete_type" => "DELETE" 
    }
  end

end
