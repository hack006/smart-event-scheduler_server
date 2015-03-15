class CreateAvailabilities < ActiveRecord::Migration
  def change
    create_table :availabilities do |t|
      t.integer :participant_id
      t.integer :slot_id
      t.string :status

      t.timestamps
    end

    add_index :availabilities, [:slot_id, :participant_id], unique: true
    add_index :availabilities, :slot_id
    add_index :availabilities, :participant_id
  end
end
