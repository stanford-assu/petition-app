require 'csv'
require 'pp' 
require 'set'

namespace :import do

    desc "Import Enrollment Data From CSV"
    task :enrollment_data, [:file] => [:environment] do |t, args|

        print("Importing from: " + args[:file])

        # - Clear all affiliations
        print("Clearing all saved affiliations\n")
        i = 0
        User.find_each do |user|
            i += 1
            user.member_type = :neither
            user.ug_year = nil
            user.coterm = false
            print("Cleared " + i.to_s + " user records!\r")
            user.save!
        end

        print("Importing new data from CSV\n")
        i = 0
        CSV.foreach(args[:file], :headers => true) do |row|
            i += 1

            if (row["Email"].downcase != (row["SUNet ID"]+"@stanford.edu"))
                warn("Email: " + row["Email"] + " does not match SUNetID: " + (row["SUNet ID"]+"@stanford.edu"))
            end

            coterm_UG = (row["Coterm UG Group Ind"] == "Y")
            coterm_GR = (row["Coterm GR Group Ind"] == "Y")
            fail "Invalid Coterm Status" if coterm_UG && coterm_GR

            coterm = coterm_UG || coterm_GRx

            careers = [ row["Career 1"], row["Career 2"], row["Career 3"]].compact

            gr_career = (careers.include? "Medicine") \
                        || (careers.include? "Graduate School of Business") \
                        || (careers.include? "Law") \
                        || (careers.include? "Graduate")

            ug_career = (careers.include? "Undergraduate")

            if !coterm && ug_career && gr_career
                warn(row["SUNet ID"] + " has UG and GR careers, but is not a Co-Term!")
            end

            if coterm && ug_career && !gr_career
                warn(row["SUNet ID"] + " has only UG career, but is a Co-Term!")
            end

            # if coterm && !ug_career && gr_career
            #     warn(row["SUNet ID"] + " has only GR career, but is a Co-Term!") #Already Confered?
            #     pp row
            # end

            if !ug_career && !gr_career
                warn(row["SUNet ID"] + " has no career!")
            end

            user = User.create_or_find_by!(id: row["SUNet ID"])

            user.coterm = coterm

            if coterm_GR
                user.grad!
            elsif coterm_UG
                user.undergrad!
            elsif gr_career
                user.grad!
            elsif ug_career
                user.undergrad!
            else
                pp row
                fail "Affiliation is not consistent!"
            end

            case row["Ug Social Class Long Desc"]
            when "-"
                user.na!
            when "UG Year 1"
                user.year1!
            when "UG Year 2"
                user.year2!
            when "UG Year 3"
                user.year3!
            when "UG Year 4"
                user.year4!
            when "UG Year 5 or more"
                user.year5!
            when "UG Year"
                user.na!
            else
                fail "Invalid UG Year"
                pp row
            end

            print("Imported " + i.to_s + " user records!\r")
            user.save!
        end
        
        print("Imported " + i.to_s + " user records!")

        # - Clear all invalid signatures
        # TODO

    end

end