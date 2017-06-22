class DaylinesController < ApplicationController
  # GET /daylines
  # GET /daylines.json
  def index
    @daylines = Dayline.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @daylines }
    end
  end

  # GET /daylines/1
  # GET /daylines/1.json
  def show
    @dayline = Dayline.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @dayline }
    end
  end

  # GET /daylines/new
  # GET /daylines/new.json
  def new
    @dayline = Dayline.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @dayline }
    end
  end

  # GET /daylines/1/edit
  def edit
    @dayline = Dayline.find(params[:id])
  end

  # POST /daylines
  # POST /daylines.json
  def create
    @dayline = Dayline.new(params[:dayline])

    respond_to do |format|
      if @dayline.save
        format.html { redirect_to @dayline, notice: 'Dayline was successfully created.' }
        format.json { render json: @dayline, status: :created, location: @dayline }
      else
        format.html { render action: "new" }
        format.json { render json: @dayline.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /daylines/1
  # PUT /daylines/1.json
  def update
    @dayline = Dayline.find(params[:id])

    respond_to do |format|
      if @dayline.update_attributes(params[:dayline])
        format.html { redirect_to @dayline, notice: 'Dayline was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @dayline.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /daylines/1
  # DELETE /daylines/1.json
  def destroy
    @dayline = Dayline.find(params[:id])
    @dayline.destroy

    respond_to do |format|
      format.html { redirect_to daylines_url }
      format.json { head :no_content }
    end
  end
end
