class RenamePreferenceToPreferenceCondition < ActiveRecord::Migration
  def change
    rename_table :preferences, :preference_conditions

    remove_column :preference_conditions, :multiplier
  end
end
