class PetitionValidator < ActiveModel::Validator
    def validate(petition)
        case petition.topic
        when "exec"
            if petition.user.neither?
                petition.errors.add :base, "Must be a member to petition for Executive President!"
            end
        when "ugs"
            if not petition.user.undergrad?
                petition.errors.add :base, "Must be an undergrad to petition for UGS!"
            end
        when "gsc"
            if not petition.user.grad?
                petition.errors.add :base, "Must be a Graduate Student to petition for Graduate Student Council!"
            end
        when "ag_petition"
            if petition.user.neither?
                petition.errors.add :base, "Must be a member to petition for Annual Grants!"
            end
        when "petition"
            if petition.user.neither?
                petition.errors.add :base, "Must be a member to submit a general petition!"
            end
        when "class_pres1"
            if not petition.user.year1?
                petition.errors.add :base, "Must be a Freshman to petition for Sophomore Class President!"
            end
        when "class_pres2"
            if not petition.user.year2?
                petition.errors.add :base, "Must be a Sophomore to petition for Junior Class President!"
            end
        when "class_pres3"
            if not petition.user.year3?
                petition.errors.add :base, "Must be a Junior to petition for Senior Class President!"
            end
        else
            petition.errors.add :base, "Petition must have a valid topic!"
        end
    end
end

class Petition < ApplicationRecord
    validates_with PetitionValidator
    include TranslateEnum
    has_paper_trail
    belongs_to :user
    has_and_belongs_to_many :signees,
        class_name: 'User',
        join_table: 'signature_join',
        before_add: :check_valid_sig
    has_rich_text :content
    validates :slug, length: { in: 1..100 }, uniqueness: true
    validates :title, length: { in: 1..100 }
    validates :agree, acceptance: { message: 'must be checked' }

    enum topic: {exec:0, ugs:1, gsc:2, ag_petition:3, petition:4, class_pres1:5, class_pres2:6, class_pres3:7}
    translate_enum :topic

    validate :has_too_many_petitions
    def has_too_many_petitions
        if user.petitions.count > 10
            errors.add :base, "You can't have more than 10 petitions. Let us know if this poses an issue."
        end
    end

    def check_valid_sig(user)
        case self.topic
        when "exec"
            if user.neither?
                errors.add :base, "Must be a member to sign Executive petitions"
                raise "Unable to sign!"
            end
        when "ugs"
            if not user.undergrad?
                errors.add :base, "Must be an Undergrad to sign UGS petitions!"
                raise "Unable to sign!"
            end
        when "gsc"
            if not user.grad?
                errors.add :base, "Must be a Graduate Student to sign Graduate Student Council petitions!"
                raise "Unable to sign!"
            end
        when "ag_petition"
            if user.neither?
                errors.add :base, "Must be a member to sign Annual Grants petitions!"
                raise "Unable to sign!"
            end
        when "petition"
            if user.neither?
                errors.add :base, "Must be a member to sign general petitions!"
                raise "Unable to sign!"
            end
        when "class_pres1"
            if not user.year1?
                errors.add :base, "Must be a Freshman to sign Sophomore Class President petitions!"
                raise "Unable to sign!"
            end
        when "class_pres2"
            if not user.year2?
                errors.add :base, "Must be a Sophomore to sign Junior Class President petitions!"
                raise "Unable to sign!"
            end
        when "class_pres3"
            if not user.year3?
                errors.add :base, "Must be a Junior to sign Senior Class President petitions!"
                raise "Unable to sign!"
            end
        end
    end

end