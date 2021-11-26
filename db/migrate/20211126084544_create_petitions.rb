class CreatePetitions < ActiveRecord::Migration[6.1]
  def change
    create_table :petitions do |t|
      t.string :slug
      t.string :title
      t.text :content

      t.timestamps
    end
  end
end
