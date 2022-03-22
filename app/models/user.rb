class User < ApplicationRecord
    devise :timeoutable
    enum member_type: [:neither, :grad, :undergrad], _default: "neither"
    enum ug_year: {"Frosh":1, "Sophmore":2, "Junior":3, "Senior":4, "Senior+":5}
    has_many :petitions
    has_and_belongs_to_many :signatures,
        class_name: 'Petition',
        join_table: 'signature_join'
end