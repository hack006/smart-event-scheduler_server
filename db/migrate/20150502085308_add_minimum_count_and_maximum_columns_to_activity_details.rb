class AddMinimumCountAndMaximumColumnsToActivityDetails < ActiveRecord::Migration
  def change
    change_table :activity_details do |t|
      t.integer :minimum_count
      t.integer :maximum_count
    end
  end
end
