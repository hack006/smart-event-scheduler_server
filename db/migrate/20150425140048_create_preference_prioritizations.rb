class CreatePreferencePrioritizations < ActiveRecord::Migration
  def change
    create_table :preference_prioritizations do |t|
      t.integer :participant_id
      t.integer :for_participant_id
      t.integer :multiplier

      t.timestamps
    end

    add_index :preference_prioritizations, :participant_id
    add_index :preference_prioritizations, :for_participant_id
  end
end
