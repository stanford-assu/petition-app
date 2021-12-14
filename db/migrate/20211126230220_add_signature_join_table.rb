class AddSignatureJoinTable < ActiveRecord::Migration[6.1]
  def change
    create_table :signature_join, id: false do |t|
      t.belongs_to :petition
      t.belongs_to :user, type: :string
    end
  end
end
