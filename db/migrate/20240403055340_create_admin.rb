class CreateAdmin < ActiveRecord::Migration[7.0]
  def change
    create_table :admin do |t|
      t.integer :singleton_guard
      t.datetime :closing_time

      t.timestamps
    end
    add_index(:admin, :singleton_guard, :unique => true)
  end
end
