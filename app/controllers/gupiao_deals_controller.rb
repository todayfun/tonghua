class GupiaoDealsController < ApplicationController
  # GET /gupiao_deals
  # GET /gupiao_deals.json
  def index
    @gupiao_deals = GupiaoDeal.paginate(:page => params[:page], :per_page => params[:per_page]||30)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @gupiao_deals }
    end
  end

  # GET /gupiao_deals/1
  # GET /gupiao_deals/1.json
  def show
    @gupiao_deal = GupiaoDeal.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @gupiao_deal }
    end
  end

  # GET /gupiao_deals/new
  # GET /gupiao_deals/new.json
  def new
    @gupiao_deal = GupiaoDeal.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @gupiao_deal }
    end
  end

  # GET /gupiao_deals/1/edit
  def edit
    @gupiao_deal = GupiaoDeal.find(params[:id])
  end

  # POST /gupiao_deals
  # POST /gupiao_deals.json
  def create
    @gupiao_deal = GupiaoDeal.new(params[:gupiao_deal])

    respond_to do |format|
      if @gupiao_deal.save
        format.html { redirect_to @gupiao_deal, notice: 'Gupiao deal was successfully created.' }
        format.json { render json: @gupiao_deal, status: :created, location: @gupiao_deal }
      else
        format.html { render action: "new" }
        format.json { render json: @gupiao_deal.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /gupiao_deals/1
  # PUT /gupiao_deals/1.json
  def update
    @gupiao_deal = GupiaoDeal.find(params[:id])

    respond_to do |format|
      if @gupiao_deal.update_attributes(params[:gupiao_deal])
        format.html { redirect_to @gupiao_deal, notice: 'Gupiao deal was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @gupiao_deal.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /gupiao_deals/1
  # DELETE /gupiao_deals/1.json
  def destroy
    @gupiao_deal = GupiaoDeal.find(params[:id])
    @gupiao_deal.destroy

    respond_to do |format|
      format.html { redirect_to gupiao_deals_url }
      format.json { head :no_content }
    end
  end
end
