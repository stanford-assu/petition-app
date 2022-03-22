class User < ApplicationRecord
    include TranslateEnum
    
    devise :timeoutable

    enum member_type: {neither:nil, grad:1, undergrad:2}, _default: :neither
    translate_enum :member_type

    enum ug_year: { na:nil, year1:1, year2:2, year3:3, year4:4, year5:5 }
    translate_enum :ug_year

    has_many :petitions
    has_and_belongs_to_many :signatures,
        class_name: 'Petition',
        join_table: 'signature_join'
end