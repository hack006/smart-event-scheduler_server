class RenamePreferenceConditionTypeColumnToConditionType < ActiveRecord::Migration
  def change
    rename_column :preference_conditions, :type, :condition_type
  end
end
