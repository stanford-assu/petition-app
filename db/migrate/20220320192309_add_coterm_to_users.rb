class AddCotermToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :coterm, :boolean, :default => false
    add_column :users, :ug_year, :integer, null: 0, default: 0
    add_column :petitions, :topic, :integer, null: 0
  end
end
