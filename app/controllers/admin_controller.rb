require 'csv'

class AdminController < ApplicationController
    before_action :require_admin

    def index
        @admin = Admin.instance
    end
  


private


end