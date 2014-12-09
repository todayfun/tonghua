class GupiaosController < ApplicationController
  # GET /gupiaos
  # GET /gupiaos.json
  def index
    @gupiaos = Gupiao.paginate(:page => params[:page], :per_page => params[:per_page]||30)
    if params[:judge]
      @gupiaos = @gupiaos.where("judge is not null and judge <> '[]'")
    elsif params[:stop]
      @gupiaos = @gupiaos.where("status='STOP'")
    end

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @gupiaos }
    end
  end

  # GET /gupiaos/1
  # GET /gupiaos/1.json
  def show
    @gupiao = Gupiao.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @gupiao }
    end
  end

  # GET /gupiaos/new
  # GET /gupiaos/new.json
  def new
    @gupiao = Gupiao.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @gupiao }
    end
  end

  # GET /gupiaos/1/edit
  def edit
    @gupiao = Gupiao.find(params[:id])
  end

  # POST /gupiaos
  # POST /gupiaos.json
  def create
    @gupiao = Gupiao.new(params[:gupiao])

    respond_to do |format|
      if @gupiao.save
        format.html { redirect_to @gupiao, notice: 'Gupiao was successfully created.' }
        format.json { render json: @gupiao, status: :created, location: @gupiao }
      else
        format.html { render action: "new" }
        format.json { render json: @gupiao.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /gupiaos/1
  # PUT /gupiaos/1.json
  def update
    @gupiao = Gupiao.find(params[:id])

    respond_to do |format|
      if @gupiao.update_attributes(params[:gupiao])
        format.html { redirect_to @gupiao, notice: 'Gupiao was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @gupiao.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /gupiaos/1
  # DELETE /gupiaos/1.json
  def destroy
    @gupiao = Gupiao.find(params[:id])
    @gupiao.destroy

    respond_to do |format|
      format.html { redirect_to gupiaos_url }
      format.json { head :no_content }
    end
  end
end
