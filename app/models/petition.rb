class Petition < ApplicationRecord
    belongs_to :user
    has_and_belongs_to_many :signees,
        class_name: 'User',
        join_table: 'signature_join'
    has_rich_text :content
    validates :slug, length: { in: 1..100 }, uniqueness: true
    validates :title, length: { in: 1..100 }
end
