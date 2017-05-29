class MonthlinesController < ApplicationController
  # GET /monthlines
  # GET /monthlines.json
  def index
    @monthlines = Monthline.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @monthlines }
    end
  end

  # GET /monthlines/1
  # GET /monthlines/1.json
  def show
    @monthline = Monthline.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @monthline }
    end
  end

  # GET /monthlines/new
  # GET /monthlines/new.json
  def new
    @monthline = Monthline.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @monthline }
    end
  end

  # GET /monthlines/1/edit
  def edit
    @monthline = Monthline.find(params[:id])
  end

  # POST /monthlines
  # POST /monthlines.json
  def create
    @monthline = Monthline.new(params[:monthline])

    respond_to do |format|
      if @monthline.save
        format.html { redirect_to @monthline, notice: 'Monthline was successfully created.' }
        format.json { render json: @monthline, status: :created, location: @monthline }
      else
        format.html { render action: "new" }
        format.json { render json: @monthline.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /monthlines/1
  # PUT /monthlines/1.json
  def update
    @monthline = Monthline.find(params[:id])

    respond_to do |format|
      if @monthline.update_attributes(params[:monthline])
        format.html { redirect_to @monthline, notice: 'Monthline was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @monthline.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /monthlines/1
  # DELETE /monthlines/1.json
  def destroy
    @monthline = Monthline.find(params[:id])
    @monthline.destroy

    respond_to do |format|
      format.html { redirect_to monthlines_url }
      format.json { head :no_content }
    end
  end
end
