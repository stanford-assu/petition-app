class User < ApplicationRecord
    devise :timeoutable
    enum member_type: [:neither, :grad, :undergrad], _default: "neither"
    has_many :petitions
    #has_and_belongs_to_many :signatures, :class_name => 'Petition'
end