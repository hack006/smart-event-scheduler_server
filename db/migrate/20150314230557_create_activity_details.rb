class CreateActivityDetails < ActiveRecord::Migration
  def change
    create_table :activity_details do |t|
      t.integer :event_id
      t.string :name
      t.string :icon
      t.integer :price
      t.string :price_per_unit
      t.string :icon

      t.timestamps
    end

    add_index :activity_details, :event_id
  end
end
