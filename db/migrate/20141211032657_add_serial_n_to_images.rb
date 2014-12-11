class AddSerialNToImages < ActiveRecord::Migration
  def change
    add_column :images, :serial_n, :integer
  end
end
