class AddUsers < ActiveRecord::Migration[6.1]
  def change
    create_table :users do |t|
      t.string :eppn, null: false, default: ""
      t.string :name
      t.integer :member_type
      t.timestamp :last_login
      t.timestamps null: false
    end

    add_index :users, :eppn, unique: true
  end
end
