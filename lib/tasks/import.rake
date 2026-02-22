require 'csv'
require 'pp' 
require 'set'

namespace :import do

    desc "Import Enrollment Data From CSV"
    task :enrollment_data, [:file] => [:environment] do |t, args|

        print("Importing from: " + args[:file] + "\n")

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
        converter = lambda { |header| header.downcase }
        CSV.foreach(args[:file], :headers => true, header_converters: converter) do |row|
            i += 1

            if (row["email"].downcase != (row["sunet id"]+"@stanford.edu"))
                warn("Email: " + row["email"] + " does not match SUNetID: " + (row["sunet id"]+"@stanford.edu"))
            end

            coterm_UG = (row["coterm ug group ind"] == "Y")
            coterm_GR = (row["coterm gr group ind"] == "Y")
            fail "Invalid Coterm Status" if coterm_UG && coterm_GR

            coterm = coterm_UG || coterm_GR

            careers = [ row["career 1"], row["career 2"], row["career 3"]].compact

            gr_career = (careers.include? "Medicine") \
                        || (careers.include? "Graduate School of Business") \
                        || (careers.include? "Law") \
                        || (careers.include? "Graduate")

            ug_career = (careers.include? "Undergraduate")

            if !coterm && ug_career && gr_career
                warn(row["sunet id"] + " has UG and GR careers, but is not a Co-Term!")
            end

            if coterm && ug_career && !gr_career
                warn(row["sunet id"] + " has only UG career, but is a Co-Term!")
            end

            # if coterm && !ug_career && gr_career
            #     warn(row["SUNet ID"] + " has only GR career, but is a Co-Term!") #Already Confered?
            #     pp row
            # end

            if !ug_career && !gr_career
                warn(row["sunet id"] + " has no career!")
            end

            user = User.create_or_find_by!(id: row["sunet id"])

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

            case row["ug social class long desc"]
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
                pp row
                fail "Invalid UG Year"
            end

            print("Imported " + i.to_s + " user records!\r")
            user.save!
        end
        
        print("Imported " + i.to_s + " user records!\n")

        # - Clear all invalid signatures
        # TODO

    end

end