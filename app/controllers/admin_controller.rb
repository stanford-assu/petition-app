require 'csv'

class AdminController < ApplicationController
    before_action :require_admin

    def index
        @app_settings = AppSettings.instance
    end
  
    # PATCH/PUT /admin
    def update
        respond_to do |format|
            print(admin_params)
            if AppSettings.instance.update(admin_params)
                @app_settings = AppSettings.instance
                format.html { render :index, notice: "Petition was successfully updated." }
            else
                @app_settings = AppSettings.instance
                format.html { render :index, status: :unprocessable_entity }
            end
        end
    end

private

    def admin_params
        params.require(:app_settings).permit(:signatures_enabled)
    end

end