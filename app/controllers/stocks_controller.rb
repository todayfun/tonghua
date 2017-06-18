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

    fd_years = fy_matrix[:fd_year].reverse
    if fd_years.blank?
      @fy_chart = nil
    else
      @fy_chart = LazyHighCharts::HighChart.new('graph') do |f|
        f.title(text: "年报-关键指标")
        f.chart(width:"900",height:"400")
        f.xAxis(categories: fd_years)
        f.yAxis(min:0) if fy_matrix[:fd_profit_base_share].compact.min > 0
        f.legend(layout:"vertical",align:"right",verticalAlign:"middle")

        arr_profit_base_share = currency_translate(fy_matrix[:fd_profit_base_share].reverse, currency, dest_currency)
        arr_price = fy_matrix[:fd_price].reverse

        pe0 = arr_price.compact.sum / arr_profit_base_share.compact.sum
        arr_virtual_profit_base_share = arr_profit_base_share.map {|v| v.nil? ? nil : (v * pe0).round(2)}

        f.series(name:"股价(#{dest_currency})",data:arr_price)
        f.series(name:"每股收益(#{dest_currency})",data:arr_profit_base_share)
        f.series(name:"每股现金(#{dest_currency})",data:currency_translate(fy_matrix[:fd_cash_base_share].reverse,currency,dest_currency))
        #f.series(name:"PE虚线",data:arr_virtual_profit_base_share) if arr_virtual_profit_base_share
      end

      @fy_uprate_chart = LazyHighCharts::HighChart.new('graph') do |f|
        f.title(text: "年报-收益增长率")
        f.chart(width:"900",height:"200")
        f.xAxis(categories: fd_years)
        f.yAxis(title:{text:"财年收益"})
        f.legend(layout:"vertical",align:"right",verticalAlign:"middle")

        f.series(name:"收益增长率",data:rate_profit_of_year.reverse)
      end

    end

    # 计算季报
    q_matrix = {fd_repdate:[],fd_price:[],fd_profit_base_share:[],fd_cash_base_share:[],fd_debt_rate:[]}
    cnt = 0
    q_profit_matrix = {idx:[],data:{}}
    @fin_reports.each do |r|
      q_matrix[:fd_repdate] << "#{r.fd_repdate.strftime '%Y%m%d'}<br/>#{fin_report_label r.fd_type}"
      q_matrix[:fd_price] << Monthline.where("code='#{@stock.code}' and day <= '#{r.fd_repdate.to_date}'").order("day desc").first.try(:close)
      q_matrix[:fd_profit_base_share] << r.fd_profit_base_share
      q_matrix[:fd_cash_base_share] << cash_base_share(@stock.stamp,@stock.gb,r.fd_cash_and_deposit)
      q_matrix[:fd_debt_rate] << stkholder_rights_of_debt(r.fd_non_liquid_debts,r.fd_stkholder_rights)

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
    if q_arr.blank?
      @q_chart = nil
      @q_rights_rate = nil
    else
      @q_uprate_chart = LazyHighCharts::HighChart.new('graph') do |f|
        f.title(text: "季报-收益增长率")
        f.chart(width:"900",height:"400")
        f.xAxis(categories: q_arr)
        f.yAxis(title:{text:"最近4季度收益"})
        f.legend(layout:"vertical",align:"right",verticalAlign:"middle")
        f.series(name:"收益同比增长率",data:rate_profit_of_quarter.reverse)
        f.series(name:"最近4季度收益(#{dest_currency})",data:currency_translate(sum_profit_of_lastyear.reverse,currency,dest_currency))
        f.series(name:"P/E",data:pe_of_lastyear.reverse)
      end

      @q_chart = LazyHighCharts::HighChart.new('graph') do |f|
        f.title(text: "季报-关键指标")
        f.chart(width:"900",height:"400")
        f.xAxis(categories: q_arr)
        f.yAxis(min:0) if q_matrix[:fd_profit_base_share].compact.min > 0
        f.legend(layout:"vertical",align:"right",verticalAlign:"middle")

        f.series(name:"股价(#{dest_currency})",data:q_matrix[:fd_price].reverse)
        f.series(name:"每股收益累计(#{dest_currency})",data:currency_translate(q_matrix[:fd_profit_base_share].reverse,currency,dest_currency))
        f.series(name:"每股现金(#{dest_currency})",data:currency_translate(q_matrix[:fd_cash_base_share].reverse,currency,dest_currency))
      end

      @q_rights_rate = LazyHighCharts::HighChart.new('graph') do |f|
        f.title(text: "季报-股东权益/长期债务占比")
        f.chart(width:"900",height:"200")
        f.xAxis(categories: q_arr)
        f.yAxis(min:0)
        f.legend(layout:"vertical",align:"right",verticalAlign:"middle")

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
