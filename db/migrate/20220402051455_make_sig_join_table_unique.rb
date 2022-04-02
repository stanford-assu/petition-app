class MakeSigJoinTableUnique < ActiveRecord::Migration[7.0]
  def change
    add_index :signature_join, [ :petition_id, :user_id ], :unique => true, :name => 'by_user_and_sig'
  end
end
