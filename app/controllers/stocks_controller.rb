class StocksController < ApplicationController
  include ApplicationHelper

  # GET /stocks
  # GET /stocks.json
  def index
    @stocks = Stock.where("(weekrise>0 and monthrise>0 or good <> '{}' ) and bad='{}'").order("monthrise desc,weekrise desc").all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @stocks }
    end
  end

  # GET /stocks/1
  # GET /stocks/1.json
  def show
    if params[:id] == "0"
      @stock = Stock.where("code='#{params[:code]}' or gpcode='#{params[:code]}'").first
    else
      @stock = Stock.find(params[:id])
    end

    if params[:refresh]
      Stock.refresh_one @stock.code
    end

    @fin_reports = FinReport.where(fd_code:@stock.code).order("fd_repdate desc").all
    dest_currency = @stock.stamp=='us' ? FinReport::CURRENCY_USD : FinReport::CURRENCY_HKD

    # 计算年报
    fy_matrix = FinReport.fy_matrix @stock,@fin_reports
    fd_years = fy_matrix[:fd_year].reverse

    weeklines = Weekline.where(code:@stock.code).where("day > '#{2.year.ago}'").order("day asc").select("day,close").all
    days = weeklines.map {|r| r.day}
    prices = weeklines.map {|r| r.close}

    @fy_chart = {}
    if !fd_years.blank?
      series = []
      #series << ["股价(#{dest_currency})",prices || fy_matrix[:fd_price].reverse]
      #@fy_chart[:price] = highchart_line("年报-股价",days || fd_years,series)

      series = []
      series << ["收益增长率",fy_matrix[:up_rate_of_profit].reverse]
      series << ["P/E",fy_matrix[:pe].reverse]
      @fy_chart[:up_rate_of_profit] = highchart_line("年报-收益增长率",fd_years,series)

      series = []
      series << ["每股收益(#{dest_currency}",fy_matrix[:fd_profit_base_share].reverse]
      series << ["每股现金(#{dest_currency})",fy_matrix[:fd_cash_base_share].reverse]
      @fy_chart[:profit_base_share] = highchart_line("年报-每股收益",fd_years,series)
    end

    # 计算季报
    q_matrix = FinReport.q_matrix @stock,@fin_reports
    q_arr = q_matrix[:fd_repdate].reverse

    @q_chart = {}
    if !q_arr.blank?
      series = []
      series << ["股价(#{dest_currency})",prices || q_matrix[:fd_price].reverse]
      @q_chart[:price_quarter] = highchart_line("季报-股价",days || q_arr,series)

      series = []
      series << ["P/E",q_matrix[:pe].reverse]
      series << ["收益增长率",q_matrix[:up_rate_of_profit].reverse]
      @q_chart[:pe_of_lastyear] = highchart_line("季报-PE",q_arr,series)

      series = []
      series << ["每股收益(#{dest_currency})",q_matrix[:fd_profit_base_share].reverse]
      series << ["4季度累计(#{dest_currency})",q_matrix[:sum_profit_of_lastyear].reverse]
      @q_chart[:profit_base_share] = highchart_line("季报-每股收益",q_arr,series)

      series = []
      series << ["经营活动净额(#{dest_currency})",q_matrix[:operating_cash].reverse]
      @q_chart[:cash_base_share] = highchart_line("季报-每股现金流",q_arr,series)

      series = []
      series << ["现金净额(#{dest_currency})",q_matrix[:fd_cash_base_share].reverse]
      series << ["投资活动净额(#{dest_currency})",q_matrix[:invest_cash].reverse]
      series << ["融资活动净额(#{dest_currency})",q_matrix[:loan_cash].reverse]
      @fy_chart[:cash_invest_base_share] = highchart_line("季报-每股投融资现金流",q_arr,series)

      series = []
      series << ["股东权益占比",q_matrix[:fd_rights_rate].reverse]
      series << ["流动负债/资产",q_matrix[:fd_debt_rate].reverse]
      @fy_chart[:debt_rate] = highchart_line("季报-权益债务",q_arr,series)
    end

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @stock }
    end
  end

  # GET /stocks/new
  # GET /stocks/new.json
  def new
    @stock = Stock.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @stock }
    end
  end

  # GET /stocks/1/edit
  def edit
    @stock = Stock.find(params[:id])
  end

  # POST /stocks
  # POST /stocks.json
  def create
    @stock = Stock.new(params[:stock])

    respond_to do |format|
      if @stock.save
        format.html { redirect_to @stock, notice: 'Stock was successfully created.' }
        format.json { render json: @stock, status: :created, location: @stock }
      else
        format.html { render action: "new" }
        format.json { render json: @stock.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /stocks/1
  # PUT /stocks/1.json
  def update
    @stock = Stock.find(params[:id])

    respond_to do |format|
      if @stock.update_attributes(params[:stock])
        format.html { redirect_to @stock, notice: 'Stock was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @stock.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /stocks/1
  # DELETE /stocks/1.json
  def destroy
    @stock = Stock.find(params[:id])
    @stock.destroy

    respond_to do |format|
      format.html { redirect_to stocks_url }
      format.json { head :no_content }
    end
  end

  def mark
    @stock = Stock.find(params[:id])
    if params[:mark]
      @stock.mark_good_or_bad! params[:mark]
    end

    respond_to do |format|
      format.html {render text:"ok"}
      format.json { render json: "ok" }
    end
  end
end
