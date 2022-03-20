class CreatePetitions < ActiveRecord::Migration[6.1]
  def change
    create_table :petitions do |t|
      t.string :slug, null: false, index: { unique: true }
      t.string :title
      t.text :content
      t.string :user_id #needed to manually override to use string id
      t.timestamps
    end
  end
end
