class FinSummary < ActiveRecord::Base
  attr_accessible :code, :matrix, :matrix_meta, :repdate, :type
  serialize :matrix,JSON
  serialize :matrix_meta,JSON

  TYPE_FY = "FY"
  TYPE_QUARTER = "QUARTER"

  def self.import
    stocks = Stock.all

    stocks.each do |stock|
      begin
        import_one_quarter stock
        #import_one_fy stock
      rescue => err
        puts "#{stock.code}:#{err}"
      end
    end

  end

  def self.import_one_quarter(stock)
    fin_reports = FinReport.where(fd_code:stock.code).order("fd_repdate desc").all
    return if fin_reports.empty?

    puts "import finSummary of quarter: #{stock.code}"
    q_matrix,q_matrix_meta = FinReport.q_summary stock,fin_reports
    fy_matrix,fy_matrix_meta = FinReport.fy_summary stock,fin_reports

    good = stock_good(stock,q_matrix,q_matrix_meta,fy_matrix)
    bad = stock_bad(stock,q_matrix,q_matrix_meta,fy_matrix)

    roe = fy_matrix[:profit_of_holderright].compact()[0,2]
    avg_roe = nil
    unless roe.empty?
      avg_roe = (roe.sum / roe.count).round(2)
    end

    up_rate_of_profit = fy_matrix[:up_rate_of_pure_profit].compact()[0,2]
    avg_up_rate_of_profit = nil
    unless up_rate_of_profit.empty?
      avg_up_rate_of_profit = (up_rate_of_profit.sum / up_rate_of_profit.count).round(2)
    end

    info = self.calc_fin_summary stock, q_matrix,fy_matrix,fin_reports

    stock.update_attributes good:good,bad:bad,roe:avg_roe, rate_of_profit:avg_up_rate_of_profit, info:info

    #FinSummary.create code:stock.code,repdate:fin_reports.first.fd_repdate,type:TYPE_QUARTER,matrix:q_matrix,matrix_meta:q_matrix_meta
  end

  def self.import_one_fy(stock)
    fin_reports = FinReport.where(fd_code:stock.code).where("fd_type='#{FinReport::TYPE_ANNUAL}'").order("fd_repdate desc").all
    return if fin_reports.empty?

    puts "import finSummary of fy: #{stock.code}"
    fy_matrix,fy_matrix_meta = FinReport.fy_summary stock,fin_reports
    #FinSummary.create code:stock.code,repdate:fin_reports.first.fd_repdate,type:TYPE_FY,matrix:fy_matrix,matrix_meta:fy_matrix_meta
  end

  # 计算最近财报收益增长率uprate > pe的
  #
  # B.按权益价值计算回报率
  # 权益=每股权益*(1+α)^n* 权益收益率=每股收益*(1+α)^n
  # 卖价=权益÷ 政府债券收益率(5%~8%)
  #
  # 复利计算: 每股收益*(1+α)^n / (5%~8%) = 买入价 * (1+β复利)^n  ，推导出:
  #    PE=(1+α)^n /  (1+β复利)^n / (5%~8%)
  #    β复利 = ((1+α)^n / (5%~8%) / PE)^1/n - 1
  #
  # 假设 n=6，债券利率7%，则:
  # β=0.2，α=0.15 => PE=0.77*14.3=10
  # β=0.2，α=0.2 => PE=1*14.3=14.3
  # β=0.2，α=0.3 => PE=1.6*14.3=23
  # β=0.2，α=0.4 => PE=2.5*14.3=36
  # β=0.2，α=0.5 => PE=3.8*14.3=54
  def self.stock_good(stock,q_matrix,q_matrix_meta,fy_matrix)
    # 3个月以前的 手工标记丢掉
    if stock.good && stock.good["mark_at"]
      good = {"mark_at"=>stock.good["mark_at"]}
    else
      good = {}
    end

    # 按权益价值计算回报率
    uprate_vs_pe = nil
    arr_rate = q_matrix[:up_rate_of_profit].compact()[0,4]
    flg = stock.pe&&stock.pe>5&&stock.pe<70

    if flg && !arr_rate.empty?
      arr_weight = [1,0.9,0.85,0.8]
      avg_rate = (self.weighted_average arr_rate, arr_weight).round(2)

      flg &&= avg_rate>15 && arr_rate.min > 5
      flg &&= q_matrix[:up_rate_of_profit][0] && q_matrix[:up_rate_of_profit][0]>15
      flg &&= q_matrix[:up_rate_of_profit][1] && q_matrix[:up_rate_of_profit][1]>5

      flg &&= stock.pe < ((1+avg_rate*0.01)/(1+0.17))**6 * 14.3

      if flg
        uprate_vs_pe = "#{(q_matrix[:up_rate_of_profit][0]/stock.pe).round(1)},avg_rate:#{avg_rate}%"
      end
    end

    # 经营现金流要增长
    up_cash_cnt = 0
    cnt = 0
    q_matrix_meta[:idx][0..-1].each do |e|
      uk = "#{e[0]},#{e[1]}"
      prev_year = e[0].to_i - 1
      prev_year_uk = "#{prev_year},#{e[1]}"

      if q_matrix_meta[:operating_cash][uk] && q_matrix_meta[:operating_cash][prev_year_uk]
        if q_matrix_meta[:operating_cash][uk] > q_matrix_meta[:operating_cash][prev_year_uk]
          up_cash_cnt += 1
        end
      end

      cnt += 1
      break if cnt>=4
    end

    if uprate_vs_pe && up_cash_cnt>=3
      good[:uprate_vs_pe] = uprate_vs_pe
    end

    # 下跌后反弹
    if stock.pe && q_matrix[:up_rate_of_profit][0] && stock.pe < q_matrix[:up_rate_of_profit][0] * 0.8 && stock.pe < 60
      rise_cnt,down_cnt = Weekline.down_and_rise_trend stock.code,7,0.015
      good[:rise_after_down] = true if rise_cnt>0 && down_cnt > 4
    end

    # 股东权益回报率很高
    high_RoE_cnt = 0
    roe = fy_matrix[:profit_of_holderright].compact()[0,4]
    unless roe.empty?
      avg_roe = roe.sum / roe.count

      roe.each_with_index do |v,i|
        if v > 18
          high_RoE_cnt += 1
        end
      end

      if high_RoE_cnt >= 2 && avg_roe > 15 && roe[0]>15 && q_matrix[:up_rate_of_profit][0] && q_matrix[:up_rate_of_profit][0]>12
        good["high_RoE"] = avg_roe.round(1)
      elsif !good.empty?
        good["avg_RoE"] = avg_roe.round(1)
      end
    end

    good
  end

  def self.calc_fin_summary(stock, q_matrix, fy_matrix, fin_reports)
    info = {}

    info[:key] = {}

    # 收益增长率分析
    arr_rate = q_matrix[:up_rate_of_profit].compact()[0,6]
    arr_rate = fy_matrix[:up_rate_of_pure_profit].compact()[0,6] if arr_rate.size <=2
    if arr_rate.size > 2
      arr_weight = [1,0.9,0.85,0.8,0.5,0.5]
      avg_rate = (self.weighted_average arr_rate, arr_weight).round(2)
      if avg_rate>1 && stock.pe > 1
        fuli = self.calc_fuli avg_rate,stock.pe,5
        info[:key]["复利(5年)"] = fuli
      end

      info["收益增长率Q"] = arr_rate
    end

    # 权益回报率
    info["权益回报率FY"] = fy_matrix[:profit_of_holderright].compact()[0,6]

    # 净利润增长率
    info["净利润增长率FY"] = fy_matrix[:up_rate_of_pure_profit].compact()[0,6]

    # 净利润/长期负债分析
    fin_report = nil
    fin_reports.each do |item|
      if item.fd_type == FinReport::TYPE_ANNUAL
        fin_report = item
        break
      end
    end

    if fin_report
      if fin_report.profit && fin_report.profit>0 && fin_report.fd_non_liquid_debts
        tmp_rate = (fin_report.profit/fin_report.fd_non_liquid_debts).round(1)
        info[:key]["净利润/长期负债"] = tmp_rate
      end
    end

    # 现金流分析
    (0..5).each do |i|
      cash_state = q_matrix[:cash_state][i]
      info["现金流#{cash_state[:name]}"]=cash_state[:label] if cash_state && cash_state[:label]
    end

    info
  end

  def self.weighted_average(arr_value, arr_weight)
    weighted_value = []
    sum_weight = 0
    arr_value.each_with_index {|v, i| weighted_value[i] = (arr_weight[i]||1)*v; sum_weight += (arr_weight[i]||1);}

    weighted_value.sum / sum_weight
  end

  # 复利计算: 每股收益*(1+α)^n / (5%~8%) = 买入价 * (1+β复利)^n  ，推导出:
  #    β复利 = ((1+α)^n / (5%~8%) / PE)^1/n - 1
  def self.calc_fuli(growth_rate,pe,n)
    fuli = ((((1+growth_rate*0.01)**n * 14.3 / pe) ** (1.0/n) - 1)*100).round(2)
    fuli
  end

  # 计算现金流不行的
  # 经营-，投资+，融资+；经营-，投资+，融资-；经营-，投资-，融资-；
  def self.stock_bad(stock,q_matrix,q_matrix_meta,fy_matrix)
    # 3个月以前的 手工标记丢掉
    if stock.bad && stock.bad["mark_at"] && stock.bad["mark_at"] > 3.month.ago.to_date.to_s
      bad = {"mark_at"=>stock.bad["mark_at"]}
    else
      bad = {}
    end

    # 现金流分析
    cash_state = q_matrix[:cash_state][0]
    if cash_state && cash_state[:level]&&cash_state[:level] < 0
      bad[:cash_label]=cash_state[:label]
    end

    # 权益负债占比
    [0,1].each do |idx|
      if q_matrix[:fd_rights_rate][idx] && q_matrix[:fd_rights_rate][idx] < 0.6
        bad["rights_rate_#{idx}"] = q_matrix[:fd_rights_rate][idx]
      end
    end

    # 收益增长率很低
    arr_rate = q_matrix[:up_rate_of_profit].compact()[0,4]
    flg = stock.pe

    if flg && !arr_rate.empty?
      avg_rate = (arr_rate.sum/arr_rate.count).round(2)

      flg &&= avg_rate<7 && arr_rate.max < 10

      if flg
        bad["low_rate_cnt"] = "avg_rate:#{avg_rate}"
      end

      max_rate = arr_rate.max
      min_rate = arr_rate.min

      if (avg_rate*2 < max_rate-min_rate) && arr_rate[0]<15
        bad["rate_wave_large"] = "rate_wave_large"
      end
    end

    # 股东权益回报率 平均不能太低
    low_RoE_cnt = 0
    roe = fy_matrix[:profit_of_holderright].compact()[0,3]
    unless roe.empty?
      avg_roe = roe.sum / roe.count

      roe.each_with_index do |v,i|
        if v < 7
          low_RoE_cnt += 1
        end
      end

      if low_RoE_cnt >= 2 || avg_roe < 8
        bad["low_RoE_cnt"] = low_RoE_cnt
      end
    end

    # 收益增长率远低于PE
    if stock.pe && q_matrix[:up_rate_of_profit][0] && q_matrix[:up_rate_of_profit][0] > 0
      if (stock.pe > q_matrix[:up_rate_of_profit][0] * 2)
        bad["uprate_lower_pe"] = [q_matrix[:up_rate_of_profit][0],stock.pe]
      end
    end

    # 净利润大幅小于长期负债的
    flg = true
    flg &&= fy_matrix[:fd_non_liquid_debts]&&fy_matrix[:fd_non_liquid_debts][0]
    flg &&= fy_matrix[:profit] && fy_matrix[:profit].compact().size>=3

    if flg
      arr_profit = fy_matrix[:profit].compact()[0,6]
      avg_profit = arr_profit.sum / arr_profit.size
      tmp_rate = (avg_profit / fy_matrix[:fd_non_liquid_debts][0]).round(2)

      if tmp_rate < 0.17
        bad["high_debts_rate"]=tmp_rate
      end
    end

    bad
  end
end
