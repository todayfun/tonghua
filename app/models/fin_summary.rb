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

    good = stock_good(stock,q_matrix,q_matrix_meta)
    bad = stock_bad(q_matrix,q_matrix_meta)
    stock.update_attributes good:good,bad:bad

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
  def self.stock_good(stock,q_matrix,q_matrix_meta)
    good = {}

    uprate_vs_pe = nil
    if stock.pe && q_matrix[:up_rate_of_profit][0] && q_matrix[:up_rate_of_profit][1]
      if (stock.pe < q_matrix[:up_rate_of_profit][0] * 0.7) && q_matrix[:up_rate_of_profit][1] > 15 && q_matrix[:up_rate_of_profit][0]>30 && stock.pe < 60
        uprate_vs_pe = (q_matrix[:up_rate_of_profit][0]/stock.pe).round(1)
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

    # 增长率要比较稳定
    ary = q_matrix[:up_rate_of_profit][0..3].compact
    flg_up_rate = true
    unless ary.empty?
      min = ary.min
      max = ary.max
      if min > 5

      else
        flg_up_rate = false
      end
    end

    if uprate_vs_pe && up_cash_cnt>=3 && flg_up_rate
      good[:uprate_vs_pe] = uprate_vs_pe
    end

    good
  end

  # 计算现金流不行的
  # 经营-，投资+，融资+；经营-，投资+，融资-；经营-，投资-，融资-；
  def self.stock_bad(q_matrix,q_matrix_meta)
    bad = {}

    [0,1].each do |idx|
      if q_matrix[:operating_cash][idx] && q_matrix[:invest_cash][idx] && q_matrix[:loan_cash][idx]
        if q_matrix[:operating_cash][idx]<0 && q_matrix[:invest_cash][idx]>0
          bad["cash_status_#{idx}"] = "cash_out_1"
        elsif q_matrix[:operating_cash][idx]<0 && q_matrix[:invest_cash][idx]<0 && q_matrix[:loan_cash][idx]<0
          bad["cash_status_#{idx}"] = "cash_out_all"
        end
      end

      if q_matrix[:fd_rights_rate][idx] && q_matrix[:fd_rights_rate][idx] < 0.8
        bad["rights_rate_#{idx}"] = q_matrix[:fd_rights_rate][idx]
      end
    end

    bad
  end
end
