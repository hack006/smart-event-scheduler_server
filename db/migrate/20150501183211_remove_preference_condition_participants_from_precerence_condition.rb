class RemovePreferenceConditionParticipantsFromPrecerenceCondition < ActiveRecord::Migration
  def change
    remove_column :preference_conditions, :preference_condition_participants2_id
    remove_column :preference_conditions, :preference_condition_participants1_id
  end
end
