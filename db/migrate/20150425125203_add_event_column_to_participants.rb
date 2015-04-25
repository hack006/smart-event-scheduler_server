class AddEventColumnToParticipants < ActiveRecord::Migration
  def change
    add_column :participants, :event_id, :integer

    add_index :participants, :event_id
  end
end
