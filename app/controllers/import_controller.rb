require 'csv'

class UserModel
    include ActiveModel::Model
    include ActiveModel::Attributes
    include TranslateEnum

    User.columns_hash.each do |name, column|
      attribute(
        name,
        User.connection.lookup_cast_type_from_column(column),
        default: column.default
      )
    end

  end

class ImportController < ApplicationController
    before_action :require_admin

    def index
    end
  
    def review
        uploaded_io = params[:csv_file]
        @upload_name = Rails.root.join('storage', uploaded_io.original_filename)
        File.open(@upload_name, 'wb') do |file|
            file.write(uploaded_io.read)
        end

        @new_user_data, @warnings = parse_data()
        @@user_data_persist = @new_user_data
        render :review, status: 422
    end

    def apply
        data_to_apply = @@user_data_persist
        if data_to_apply.length > 0
            ImportJob.perform_later data_to_apply
            flash[:error] = "Started Job to import " + data_to_apply.length.to_s + " Records!"
            redirect_to action: 'index', controller: 'import'
        else
            flash[:error] = "No Data to Apply!"
            redirect_to action: 'index', controller: 'import'
        end
    end

private

    def parse_data

        print("Importing new data from CSV")
        i = 0
        warnings = Array.new
        user_data = Array.new
        CSV.foreach(params[:csv_file], :headers => true) do |row|
            i += 1

            if (row["Email"].downcase != (row["SUNet ID"]+"@stanford.edu"))
                warnings << ("Email: " + row["Email"] + " does not match SUNetID: " + (row["SUNet ID"]+"@stanford.edu") + "\n")
            end

            coterm_UG = (row["Coterm UG Group Ind"] == "Y")
            coterm_GR = (row["Coterm GR Group Ind"] == "Y")
            fail "Invalid Coterm Status" if coterm_UG && coterm_GR

            coterm = coterm_UG || coterm_GR

            careers = [ row["Career 1"], row["Career 2"], row["Career 3"]].compact

            gr_career = (careers.include? "Medicine") \
                        || (careers.include? "Graduate School of Business") \
                        || (careers.include? "Law") \
                        || (careers.include? "Graduate")

            ug_career = (careers.include? "Undergraduate")

            if !coterm && ug_career && gr_career
                warnings << (row["SUNet ID"] + " has UG and GR careers, but is not a Co-Term!" + "\n") 
            end

            if coterm && ug_career && !gr_career
                warnings << (row["SUNet ID"] + " has only UG career, but is a Co-Term!" + "\n")
            end

            if !ug_career && !gr_career
                warnings << (row["SUNet ID"] + " has no career!" + "\n")
            end
            
            user = UserModel.new(id: row["SUNet ID"])

            user.coterm = coterm

            if coterm_GR
                user.member_type = User.member_types['grad']
            elsif coterm_UG
                user.member_type = User.member_types['undergrad']
            elsif gr_career
                user.member_type = User.member_types['grad']
            elsif ug_career
                user.member_type = User.member_types['undergrad']
            else
                pp row
                fail "Affiliation is not consistent!"
            end

            case row["Ug Social Class Long Desc"]
            when "-"
                user.ug_year = User.ug_years['na']
            when "UG Year 1"
                user.ug_year = User.ug_years['year1']
            when "UG Year 2"
                user.ug_year = User.ug_years['year2']
            when "UG Year 3"
                user.ug_year = User.ug_years['year3']
            when "UG Year 4"
                user.ug_year = User.ug_years['year4']
            when "UG Year 5 or more"
                user.ug_year = User.ug_years['year5']
            when "UG Year"
                user.ug_year = User.ug_years['na']
            else
                pp row
                fail "Invalid UG Year"
            end

            
            user_data << user
        end
        
        warnings << ("Imported " + i.to_s + " user records!" + "\n")
        return user_data, warnings

    end
end