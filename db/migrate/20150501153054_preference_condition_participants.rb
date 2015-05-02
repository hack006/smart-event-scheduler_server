class PreferenceConditionParticipants < ActiveRecord::Migration
  def change
    create_table :preference_condition_participant1s do |t|
      t.integer :preference_condition_id
      t.integer :participant_id

      t.timestamps
    end

    add_index :preference_condition_participant1s, :preference_condition_id, :name => 'preference_condition_participants1_condition_id_index'
    add_index :preference_condition_participant1s, :participant_id

    create_table :preference_condition_participant2s do |t|
      t.integer :preference_condition_id
      t.integer :participant_id

      t.timestamps
    end

    add_index :preference_condition_participant2s, :preference_condition_id, :name => 'preference_condition_participants2_condition_id_index'
    add_index :preference_condition_participant2s, :participant_id

    change_table :preference_conditions do |t|
      t.remove :participant1_id
      t.remove :participant2_id

      t.integer :preference_condition_participants1_id
      t.integer :preference_condition_participants2_id
    end

    add_index :preference_conditions, :preference_condition_participants1_id, :name => 'preference_conditions_participants1_list'
    add_index :preference_conditions, :preference_condition_participants2_id, :name => 'preference_conditions_participants2_list'
  end
end