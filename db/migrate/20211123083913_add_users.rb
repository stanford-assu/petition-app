class AddUsers < ActiveRecord::Migration[6.1]
  def change
    create_table :users, id: :string do |t|
      t.string :name
      t.integer :member_type
      t.timestamp :last_login
      t.timestamps null: false
    end
  end
end
