class WeeklinesController < ApplicationController
  # GET /weeklines
  # GET /weeklines.json
  def index
    @weeklines = Weekline.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @weeklines }
    end
  end

  # GET /weeklines/1
  # GET /weeklines/1.json
  def show
    @weekline = Weekline.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @weekline }
    end
  end

  # GET /weeklines/new
  # GET /weeklines/new.json
  def new
    @weekline = Weekline.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @weekline }
    end
  end

  # GET /weeklines/1/edit
  def edit
    @weekline = Weekline.find(params[:id])
  end

  # POST /weeklines
  # POST /weeklines.json
  def create
    @weekline = Weekline.new(params[:weekline])

    respond_to do |format|
      if @weekline.save
        format.html { redirect_to @weekline, notice: 'Weekline was successfully created.' }
        format.json { render json: @weekline, status: :created, location: @weekline }
      else
        format.html { render action: "new" }
        format.json { render json: @weekline.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /weeklines/1
  # PUT /weeklines/1.json
  def update
    @weekline = Weekline.find(params[:id])

    respond_to do |format|
      if @weekline.update_attributes(params[:weekline])
        format.html { redirect_to @weekline, notice: 'Weekline was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @weekline.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /weeklines/1
  # DELETE /weeklines/1.json
  def destroy
    @weekline = Weekline.find(params[:id])
    @weekline.destroy

    respond_to do |format|
      format.html { redirect_to weeklines_url }
      format.json { head :no_content }
    end
  end
end
