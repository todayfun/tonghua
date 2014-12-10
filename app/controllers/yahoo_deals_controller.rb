class YahooDealsController < ApplicationController
  # GET /yahoo_deals
  # GET /yahoo_deals.json
  def index
    @yahoo_deals = YahooDeal.paginate(:page => params[:page], :per_page => params[:per_page]||30)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @yahoo_deals }
    end
  end

  # GET /yahoo_deals/1
  # GET /yahoo_deals/1.json
  def show
    @yahoo_deal = YahooDeal.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @yahoo_deal }
    end
  end

  # GET /yahoo_deals/new
  # GET /yahoo_deals/new.json
  def new
    @yahoo_deal = YahooDeal.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @yahoo_deal }
    end
  end

  # GET /yahoo_deals/1/edit
  def edit
    @yahoo_deal = YahooDeal.find(params[:id])
  end

  # POST /yahoo_deals
  # POST /yahoo_deals.json
  def create
    @yahoo_deal = YahooDeal.new(params[:yahoo_deal])

    respond_to do |format|
      if @yahoo_deal.save
        format.html { redirect_to @yahoo_deal, notice: 'Yahoo deal was successfully created.' }
        format.json { render json: @yahoo_deal, status: :created, location: @yahoo_deal }
      else
        format.html { render action: "new" }
        format.json { render json: @yahoo_deal.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /yahoo_deals/1
  # PUT /yahoo_deals/1.json
  def update
    @yahoo_deal = YahooDeal.find(params[:id])

    respond_to do |format|
      if @yahoo_deal.update_attributes(params[:yahoo_deal])
        format.html { redirect_to @yahoo_deal, notice: 'Yahoo deal was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @yahoo_deal.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /yahoo_deals/1
  # DELETE /yahoo_deals/1.json
  def destroy
    @yahoo_deal = YahooDeal.find(params[:id])
    @yahoo_deal.destroy

    respond_to do |format|
      format.html { redirect_to yahoo_deals_url }
      format.json { head :no_content }
    end
  end
end
