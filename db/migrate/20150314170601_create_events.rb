class CreateEvents < ActiveRecord::Migration
  def change
    create_table :events do |t|
      t.string :name
      t.text :description
      t.datetime :voting_deadline
      t.integer :manager_id

      t.timestamps
    end

    add_index :events, :manager_id
  end
end
