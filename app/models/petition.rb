class Petition < ApplicationRecord
    belongs_to :user
    has_and_belongs_to_many :signees, :class_name => 'User'
    has_rich_text :content
end
