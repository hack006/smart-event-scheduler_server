class ChangePreferenceConditionUsersToParticipants < ActiveRecord::Migration
  def change
    rename_column :preference_conditions, :user1_id, :participant1_id
    rename_column :preference_conditions, :user2_id, :participant2_id
  end
end
