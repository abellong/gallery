class CreateThumbnails < ActiveRecord::Migration
  def change
    create_table :thumbnails do |t|
      t.belongs_to :image
      t.string :url
      t.string :params

      t.timestamps
    end
  end
end
