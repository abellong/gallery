class AddAlbumIdToImage < ActiveRecord::Migration
  def change
    add_column :images, :album_id, :integer
  end
end
