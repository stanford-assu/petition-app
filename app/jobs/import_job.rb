class ImportJob < ApplicationJob
  queue_as :default

  def perform(*args)
    clear_old_user_data()
    print("Applying: " + data_to_apply.length.to_s + "\n")
    data_to_apply.each do |new_data|
        user = User.create_or_find_by!(id: new_data.id)
        user.member_type = new_data.member_type
        user.ug_year = new_data.ug_year
        user.coterm = new_data.coterm
        user.save!
    end
    
    # callback here
    # flash[:error] = "Successfully Imported " + data_to_apply.length.to_s + " Records!"
    # redirect_to action: 'index', controller: 'users'
  end

  def clear_old_user_data
    print("Clearing all saved affiliations")
    User.find_each do |user|
        user.member_type = :neither
        user.ug_year = nil
        user.coterm = false
        user.save!
    end
  end

end
