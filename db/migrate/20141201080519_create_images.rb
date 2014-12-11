class CreateImages < ActiveRecord::Migration
  def change
    create_table :images do |t|
      t.has_attached_file :file
      t.belongs_to :user

      t.timestamps
    end
  end
end
