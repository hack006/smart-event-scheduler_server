class CreateParticipants < ActiveRecord::Migration
  def change
    create_table :participants do |t|
      t.text :note
      t.integer :user_id

      t.timestamps
    end

    add_index :participants, :user_id
  end
end
