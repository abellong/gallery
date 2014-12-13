class Thumbnail < ActiveRecord::Base
  belongs_to :image

  after_destroy :delete_cloud_file

  protected

    def delete_cloud_file
      Qiniu::RS.delete(ENV['BUCKET_NAME'], self.path)
    end
end
