class StocksController < ApplicationController
  include ApplicationHelper

  # GET /stocks
  # GET /stocks.json
  def index
    @stocks = Stock.where("weekrise>0").where("monthrise>0").order("monthrise desc,weekrise desc")

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @stocks }
    end
  end

  # GET /stocks/1
  # GET /stocks/1.json
  def show
    @stock = Stock.find(params[:id])

    @fin_reports = FinReport.where(fd_code:@stock.code).order("fd_repdate desc").all

    fy_matrix = {fd_year:[],fd_profit_base_share:[],fd_cash_base_share:[],fd_debt_rate:[]}

    @fin_reports.each do |r|
      next if r.fd_type != FinReport::TYPE_ANNUAL

      fy_matrix[:fd_year] << r.fd_year
      fy_matrix[:fd_profit_base_share] << r.fd_profit_base_share
      fy_matrix[:fd_cash_base_share] << cash_base_share(@stock.stamp,@stock.gb,r.fd_cash_and_deposit)
      fy_matrix[:fd_debt_rate] << stkholder_rights_of_debt(r.fd_non_liquid_debts,r.fd_stkholder_rights)
    end

    q_matrix = {fd_repdate:[],fd_profit_base_share:[],fd_cash_base_share:[],fd_debt_rate:[]}
    cnt = 0
    @fin_reports.each do |r|
      q_matrix[:fd_repdate] << "#{r.fd_repdate.to_date}-#{fin_report_label r.fd_type}"
      q_matrix[:fd_profit_base_share] << r.fd_profit_base_share
      q_matrix[:fd_cash_base_share] << cash_base_share(@stock.stamp,@stock.gb,r.fd_cash_and_deposit)
      q_matrix[:fd_debt_rate] << stkholder_rights_of_debt(r.fd_non_liquid_debts,r.fd_stkholder_rights)

      cnt += 1
      break if cnt > 4
    end

    fd_years = fy_matrix[:fd_year].reverse
    if fd_years.blank?
      @fy_chart = nil
    else
      @fy_chart = LazyHighCharts::HighChart.new('graph') do |f|
        f.title(text: "年报-关键指标")
        f.xAxis(categories: fd_years)
        f.legend(layout:"vertical",align:"right",verticalAlign:"middle")

        f.series(name:"每股收益(元)",data:fy_matrix[:fd_profit_base_share].reverse)
        f.series(name:"每股现金(元)",data:fy_matrix[:fd_cash_base_share].reverse)
        f.series(name:"股东权益占比",data:fy_matrix[:fd_debt_rate].reverse)
      end
    end

    q_arr = q_matrix[:fd_repdate].reverse
    if q_arr.blank?
      @q_chart = nil
    else
      @q_chart = LazyHighCharts::HighChart.new('graph') do |f|
        f.title(text: "季报-关键指标")
        f.xAxis(categories: q_arr)
        f.legend(layout:"vertical",align:"right",verticalAlign:"middle")

        f.series(name:"每股收益(元)",data:q_matrix[:fd_profit_base_share].reverse)
        f.series(name:"每股现金(元)",data:q_matrix[:fd_cash_base_share].reverse)
        f.series(name:"股东权益占比",data:q_matrix[:fd_debt_rate].reverse)
      end
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
end
