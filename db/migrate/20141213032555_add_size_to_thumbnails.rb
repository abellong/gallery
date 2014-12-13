class AddSizeToThumbnails < ActiveRecord::Migration
  def change
    add_column :thumbnails, :width, :integer
    add_column :thumbnails, :height, :integer
  end
end
