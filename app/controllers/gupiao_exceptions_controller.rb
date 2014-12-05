class GupiaoExceptionsController < ApplicationController
  # GET /gupiao_exceptions
  # GET /gupiao_exceptions.json
  def index
    @gupiao_exceptions = GupiaoException.paginate(:page => params[:page], :per_page => params[:per_page]||30)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @gupiao_exceptions }
    end
  end

  # GET /gupiao_exceptions/1
  # GET /gupiao_exceptions/1.json
  def show
    @gupiao_exception = GupiaoException.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @gupiao_exception }
    end
  end

  # GET /gupiao_exceptions/new
  # GET /gupiao_exceptions/new.json
  def new
    @gupiao_exception = GupiaoException.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @gupiao_exception }
    end
  end

  # GET /gupiao_exceptions/1/edit
  def edit
    @gupiao_exception = GupiaoException.find(params[:id])
  end

  # POST /gupiao_exceptions
  # POST /gupiao_exceptions.json
  def create
    @gupiao_exception = GupiaoException.new(params[:gupiao_exception])

    respond_to do |format|
      if @gupiao_exception.save
        format.html { redirect_to @gupiao_exception, notice: 'Gupiao exception was successfully created.' }
        format.json { render json: @gupiao_exception, status: :created, location: @gupiao_exception }
      else
        format.html { render action: "new" }
        format.json { render json: @gupiao_exception.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /gupiao_exceptions/1
  # PUT /gupiao_exceptions/1.json
  def update
    @gupiao_exception = GupiaoException.find(params[:id])

    respond_to do |format|
      if @gupiao_exception.update_attributes(params[:gupiao_exception])
        format.html { redirect_to @gupiao_exception, notice: 'Gupiao exception was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @gupiao_exception.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /gupiao_exceptions/1
  # DELETE /gupiao_exceptions/1.json
  def destroy
    @gupiao_exception = GupiaoException.find(params[:id])
    @gupiao_exception.destroy

    respond_to do |format|
      format.html { redirect_to gupiao_exceptions_url }
      format.json { head :no_content }
    end
  end
end
