class User < ApplicationRecord
    devise :timeoutable
    enum member_type: [:neither, :grad, :undergrad], _default: "neither"
end