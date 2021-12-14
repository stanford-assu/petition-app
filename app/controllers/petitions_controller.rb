class PetitionsController < ApplicationController
  before_action :set_petition, only: %i[ show edit update destroy sign unsign]
  before_action :set_petition_by_slug, only: %i[ by_slug ]

  # GET /petitions or /petitions.json
  def index
    @petitions = Petition.all
  end

  # GET /petitions/1 or /petitions/1.json
  def show
    pp @petition.signees.exists?(current_user.id)
  end

  def by_slug
    render "show_public"
  end

  # GET /petitions/new
  def new
    @petition = Petition.new
  end

  # GET /petitions/1/edit
  def edit
  end

  def sign
    if !@petition.signees.exists?(current_user.id)
      current_user.signatures << @petition
      flash[:notice] = 'Petition signed!'
    end
    redirect_back(fallback_location: root_path)
  end

  def unsign
    if @petition.signees.exists?(current_user.id)
      current_user.signatures.delete(@petition)
      flash[:notice] = 'Petition signature removed!'
    end
    redirect_back(fallback_location: root_path)
  end

  # POST /petitions or /petitions.json
  def create
    @petition = current_user.petitions.new(petition_params)
    respond_to do |format|
      if @petition.save
        format.html { redirect_to @petition, notice: "Petition was successfully created." }
        format.json { render :show, status: :created, location: @petition }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @petition.errors, status: :unprocessable_entity }
      end
    end
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

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_petition
      @petition = Petition.find(params[:id])
    end
    
    def set_petition_by_slug
      @petition = Petition.find_by!(slug: params[:slug])
    end

    # Only allow a list of trusted parameters through.
    def petition_params
      params.require(:petition).permit(:slug, :title, :content)
    end
end
