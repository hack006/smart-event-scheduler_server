class CreateTimeDetails < ActiveRecord::Migration
  def change
    create_table :time_details do |t|
      t.integer :event_id
      t.datetime :from
      t.datetime :until
      t.string :duration_type

      t.timestamps

    end

    add_index :time_details, :event_id
  end
end
