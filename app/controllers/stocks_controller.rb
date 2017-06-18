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
    if params[:id] == "0"
      @stock = Stock.find_by_code(params[:code])
    else
      @stock = Stock.find(params[:id])
    end

    if params[:refresh]
      Stock.refresh_one @stock.code
    end

    @fin_reports = FinReport.where(fd_code:@stock.code).order("fd_repdate desc").all

    dest_currency = @stock.stamp=='us' ? FinReport::CURRENCY_USD : FinReport::CURRENCY_HKD
    currency = nil

    # 计算年报
    fy_matrix = {fd_year:[],fd_price:[],fd_profit_base_share:[],fd_cash_base_share:[],fd_debt_rate:[],fd_virtual_profit_base_share:[]}
    @fin_reports.each do |r|
      next if r.fd_type != FinReport::TYPE_ANNUAL

      currency = r.currency
      fy_matrix[:fd_year] << r.fd_year
      fy_matrix[:fd_price] << Monthline.where("code='#{@stock.code}' and day <= '#{r.fd_repdate.to_date}'").order("day desc").first.try(:close)
      fy_matrix[:fd_profit_base_share] << r.fd_profit_base_share
      fy_matrix[:fd_cash_base_share] << cash_base_share(@stock.stamp,@stock.gb,r.fd_cash_and_deposit)
      fy_matrix[:fd_debt_rate] << stkholder_rights_of_debt(r.fd_non_liquid_debts,r.fd_stkholder_rights)
    end

    rate_profit_of_year = []
    fy_matrix[:fd_profit_base_share].each_with_index do |e,idx|
      rate = if e && fy_matrix[:fd_profit_base_share][idx+1]
               ((e - fy_matrix[:fd_profit_base_share][idx+1]) * 100/ fy_matrix[:fd_profit_base_share][idx+1]).round(2)
             else
               nil
             end

      rate_profit_of_year << rate
    end

    pe_of_fy = []
    fy_matrix[:fd_price].each_with_index do |p,idx|
      pe = if p && fy_matrix[:fd_profit_base_share][idx] && fy_matrix[:fd_profit_base_share][idx]>0
             (p / currency_translate(fy_matrix[:fd_profit_base_share][idx],currency,dest_currency)).round(2)
           else
             nil
           end

      pe_of_fy << pe
    end

    fd_years = fy_matrix[:fd_year].reverse
    @fy_chart = {}
    if !fd_years.blank?
      series = []
      series << ["股价(#{dest_currency})",fy_matrix[:fd_price].reverse]
      @fy_chart[:price] = highchart_line("年报-股价",fd_years,series)

      series = []
      series << ["每股收益(#{dest_currency}",currency_translate(fy_matrix[:fd_profit_base_share].reverse, currency, dest_currency)]
      series << ["每股现金(#{dest_currency})",currency_translate(fy_matrix[:fd_cash_base_share].reverse,currency,dest_currency)]
      @fy_chart[:profit_base_share] = highchart_line("年报-每股收益",fd_years,series)

      series = []
      series << ["收益增长率",rate_profit_of_year.reverse]
      series << ["P/E",pe_of_fy.reverse]
      @fy_chart[:rate_profit_of_year] = highchart_line("年报-收益增长率",fd_years,series)
    end

    # 计算季报
    q_matrix = {fd_repdate:[],fd_price:[],fd_profit_base_share:[],fd_cash_base_share:[],fd_debt_rate:[],fd_rights_rate:[]}
    cnt = 0
    q_profit_matrix = {idx:[],data:{}}
    @fin_reports.each do |r|
      q_matrix[:fd_repdate] << "#{r.fd_repdate.strftime '%Y%m%d'}<br/>#{fin_report_label r.fd_type}"
      q_matrix[:fd_price] << Monthline.where("code='#{@stock.code}' and day <= '#{r.fd_repdate.to_date}'").order("day desc").first.try(:close)
      q_matrix[:fd_profit_base_share] << r.fd_profit_base_share
      q_matrix[:fd_cash_base_share] << cash_base_share(@stock.stamp,@stock.gb,r.fd_cash_and_deposit)
      q_matrix[:fd_rights_rate] << stkholder_rights_of_debt(r.fd_non_liquid_debts,r.fd_stkholder_rights)
      q_matrix[:fd_debt_rate] << debt_rate_of_asset(r.fd_liquid_assets,r.fd_liquid_debts)

      q_profit_matrix[:data]["#{r.fd_year},#{r.fd_type}"] = r.fd_profit_base_share
      q_profit_matrix[:idx] << [r.fd_year,r.fd_type]

      cnt += 1
      break if cnt > 12
    end

    rate_profit_of_quarter = []
    sum_profit_of_lastyear = []
    q_profit_matrix[:idx][0..-1].each_with_index do |e,idx|
      uk = "#{e[0]},#{e[1]}"
      prev_year = e[0].to_i - 1
      prev_year_uk = "#{prev_year},#{e[1]}"
      rate = if q_profit_matrix[:data][uk] && q_profit_matrix[:data][prev_year_uk]
               ((q_profit_matrix[:data][uk] - q_profit_matrix[:data][prev_year_uk]) * 100/ q_profit_matrix[:data][prev_year_uk]).round(2)
             else
               nil
             end
      rate_profit_of_quarter << rate

      prev_fy_uk = "#{prev_year},#{FinReport::TYPE_ANNUAL}"
      v = if q_profit_matrix[:data][uk] && q_profit_matrix[:data][prev_fy_uk] && q_profit_matrix[:data][prev_year_uk]
            (q_profit_matrix[:data][uk] + (q_profit_matrix[:data][prev_fy_uk] - q_profit_matrix[:data][prev_year_uk])).round(2)
          else
            nil
          end
      sum_profit_of_lastyear << v
    end

    pe_of_lastyear = []
    q_matrix[:fd_price].each_with_index do |p,idx|
      pe = if p && sum_profit_of_lastyear[idx] && sum_profit_of_lastyear[idx]>0
             (p / currency_translate(sum_profit_of_lastyear[idx],currency,dest_currency)).round(2)
           else
             nil
           end

      pe_of_lastyear << pe
    end

    q_arr = q_matrix[:fd_repdate].reverse
    @q_chart = {}
    if !q_arr.blank?
      series = []
      series << ["股价(#{dest_currency})",q_matrix[:fd_price].reverse]
      series << ["每股现金(#{dest_currency})",currency_translate(q_matrix[:fd_cash_base_share].reverse,currency,dest_currency)]
      @q_chart[:price_quarter] = highchart_line("季报-股价",q_arr,series)

      series = []
      series << ["P/E",pe_of_lastyear.reverse]
      series << ["收益增长率",rate_profit_of_quarter.reverse]
      @q_chart[:pe_of_lastyear] = highchart_line("季报-PE",q_arr,series)

      series = []
      series << ["每股收益累计(#{dest_currency})",currency_translate(q_matrix[:fd_profit_base_share].reverse,currency,dest_currency)]
      series << ["最近4季度收益(#{dest_currency})",currency_translate(sum_profit_of_lastyear.reverse,currency,dest_currency)]
      @q_chart[:profit_base_share] = highchart_line("季报-每股收益",q_arr,series)

      series = []
      series << ["股东权益占比",q_matrix[:fd_rights_rate].reverse]
      series << ["流动负债/资产",q_matrix[:fd_debt_rate].reverse]
      @q_chart[:debt_rate] = highchart_line("季报-权益债务",q_arr,series)
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
