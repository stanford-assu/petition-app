class PetitionsController < ApplicationController
  before_action :set_petition, only: %i[ show edit update destroy ]
  before_action :set_petition_by_slug, only: %i[ by_slug sign unsign ]
  before_action :check_editable, only: %i[ edit update ]
  before_action :require_user, :except => [ :by_slug, :leaderboard ]
  before_action :check_petition_access, only: [ :show, :edit, :update, :destroy ]

  # GET /petitions or /petitions.json
  def index
    if current_user.admin
      @petitions = Petition.all
    else
      @petitions = Petition.where(:user_id => current_user.id)
    end
  end

  def leaderboard
    @petitions = Petition.all.sort_by{ |a| -a.signees.length } # Sort by decending signature count
  end

  # GET /petitions/1 or /petitions/1.json
  def show
  end

  def by_slug
    render "show_public"
  end

  def sign
  #### Uncomment to allow signing!
   @petition.signees << current_user
   render "show_public"
  rescue
    render "show_public"
  end

  def unsign
  #### Uncomment to allow signing!
   @petition.signees.delete(current_user)
   render "show_public"
  rescue
    render "show_public"
  end

  # GET /petitions/new
  def new
    @petition = Petition.new
  end

  # GET /petitions/1/edit
  def edit
  end

  # POST /petitions or /petitions.json
  def create
    @petition = current_user.petitions.new(petition_params)
    #if @petition.petition?
      respond_to do |format|
        if @petition.save
          format.html { redirect_to @petition, notice: "Petition was successfully created." }
          format.json { render :show, status: :created, location: @petition }
        else
          format.html { render :new, status: :unprocessable_entity }
          format.json { render json: @petition.errors, status: :unprocessable_entity }
        end
      end
    #else
    #  respond_to do |format|
    #    format.html { redirect_to petitions_url, notice: "Petition creation is disabled at this time." }
    #  end
    #end
  end

  # PATCH/PUT /petitions/1 or /petitions/1.json
  def update
    respond_to do |format|
      if @petition.update(petition_params)
        format.html { redirect_to @petition, notice: "Petition was successfully updated." }
        format.json { render :show, status: :ok, location: @petition }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @petition.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /petitions/1 or /petitions/1.json
  def destroy
    @petition.destroy
    respond_to do |format|
      format.html { redirect_to petitions_url, notice: "Petition was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  # GET /audit or /audit.json
  def audit
    @petitions = Petition.all
    render formats: :json
  end

  private

    # If more than 10 signees, don't let the use edit
    def check_editable
      if (@petition.signees.length > 10) && (!current_user.admin)
        flash[:notice] = 'Petitions with more than 10 signatures cannot be edited, please reach out to elections@assu.stanford.edu for help.'
        redirect_to action: 'show'
      end
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_petition
      @petition = Petition.find(params[:id])
    end
    
    def set_petition_by_slug
      @petition = Petition.find_by!(slug: params[:slug].downcase)
    end

    # Only allow a list of trusted parameters through.
    def petition_params
      new_params = params.require(:petition).permit(:slug, :title, :topic, :content, :agree)
      new_params[:slug].gsub!(/[^0-9a-z\-_]/i, '') #Trim special chars from slug
      new_params[:slug].downcase!
      new_params
    end

    def check_petition_access
      unless (current_user.admin || @petition.user_id == current_user.id)
        redirect_to action: 'index', controller: 'application'
      end
    end
end
