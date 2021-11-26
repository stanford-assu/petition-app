class AddSignTable < ActiveRecord::Migration[6.1]
  def change
    create_table :petitions_users, id: false do |t|
      t.belongs_to :petition
      t.belongs_to :user
    end
  end
end
