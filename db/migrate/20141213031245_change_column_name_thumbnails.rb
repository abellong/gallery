class ChangeColumnNameThumbnails < ActiveRecord::Migration
  def self.up
    rename_column :thumbnails, :url, :path
  end

  def self.down
    rename_column :thumbnails, :path, :url
  end
end
