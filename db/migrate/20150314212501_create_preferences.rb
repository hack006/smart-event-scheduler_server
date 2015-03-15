class CreatePreferences < ActiveRecord::Migration
  def change
    create_table :preferences do |t|
      t.string :type
      t.integer :participant_id
      t.integer :user1_id
      t.integer :user2_id
      t.integer :multiplier

      t.timestamps
    end

    add_index :preferences, :participant_id
    add_index :preferences, :user1_id
    add_index :preferences, :user2_id
  end
end
