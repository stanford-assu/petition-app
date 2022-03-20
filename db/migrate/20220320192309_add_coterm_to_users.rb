class AddCotermToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :coterm, :boolean, :default => false
  end
end
