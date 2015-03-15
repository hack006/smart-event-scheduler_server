class CreateSlots < ActiveRecord::Migration
  def change
    create_table :slots do |t|
      t.integer :event_id
      t.string :note

      t.timestamps
    end

    add_index :slots, :event_id
  end
end
