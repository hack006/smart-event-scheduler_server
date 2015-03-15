class AddSlugColumnToEvent < ActiveRecord::Migration
  def change
    change_table :events do |t|
      t.column :slug, :string
    end

    add_index :events, :slug, unique: true
  end
end
