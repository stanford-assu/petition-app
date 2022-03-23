class Petition < ApplicationRecord
    include TranslateEnum
    has_paper_trail
    belongs_to :user
    has_and_belongs_to_many :signees,
        class_name: 'User',
        join_table: 'signature_join'
    has_rich_text :content
    validates :slug, length: { in: 1..100 }, uniqueness: true
    validates :title, length: { in: 1..100 }

    enum topic: {exec:0, ugs:1, ag_petition:2, petition:3, class_pres1:4, class_pres2:5, class_pres3:6}
    translate_enum :topic
end
