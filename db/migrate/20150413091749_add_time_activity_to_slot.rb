class AddTimeActivityToSlot < ActiveRecord::Migration
  def change
    add_column :slots, :time_detail_id, :integer
    add_column :slots, :activity_detail_id, :integer

    add_index :slots, :time_detail_id
    add_index :slots, :activity_detail_id
  end
end
