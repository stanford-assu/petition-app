class CreateAppSettings < ActiveRecord::Migration[7.0]
  def change
    create_table :app_settings do |t|
      t.integer  :singleton_guard

      t.boolean  :signatures_enabled, default: true

      t.timestamps
    end
    add_index(:app_settings, :singleton_guard, :unique => true)
  end
end