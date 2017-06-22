class FinReport < ActiveRecord::Base
  attr_accessible :fd_code,
                  :fd_profit_after_share, # 基本每股收益
                  :fd_profit_base_share, # 稀释每股收益
                  :fd_profit_after_tax, # 税后盈利
                  :fd_repdate, # 财报日期
                  :fd_turnover, # 营业额
                  :fd_type, # 财报类型
                  :fd_year, # 财年
                  :fd_dividend_base_share,# 股息
                  :fd_non_liquid_debts, # 长期负债
                  :fd_stkholder_rights, # 股东权益
                  :fd_liquid_debts, # 流动负债，短期负债
                  :fd_liquid_assets, # 流动资产
                  :fd_cash_and_deposit, # 现金与现金等价物
                  :currency, # 财报中的货币
                  :operating_cash, # 经营活动现金流量净额
                  :invest_cash, # 投资活动现金流量净额
                  :loan_cash # 筹资活动现金流量净额

  TYPE_Q1 = 4
  TYPE_Q2 = 3
  TYPE_Q3 = 2
  TYPE_ANNUAL = 1
  TYPE_SUM_Q2 = 6
  TYPE_SUM_Q3 = 9

  FIN_RPT_UNIT=10000   # 万，同花顺的财报以 万元为单位

  CURRENCY_CNY = "CNY" # 人民币
  CURRENCY_HKD = "HKD" # 港元
  CURRENCY_USD = "USD" # 美元

  CNY2USD_RATE = 0.1468
  CNY2HKD_RATE = 1.1454
  HKD2USD_RATE = 0.1282
  USD2HKD_RATE = 7.7999

  def self.import_finRpt
    stocks = Stock.all
    ignored_codes = Runlog.ignored Runlog::NAME_FINRPT,[Runlog::STATUS_DISABLE,Runlog::STATUS_DISABLE],1.week.ago
    stocks.each do |stock|
      begin
        next if ignored_codes.include?(stock.code)

        status = import_finRpt_one stock
        Runlog.update_log stock.code,Runlog::NAME_FINRPT, status
      rescue => err
        puts "import_finRpt exception for #{stock.code}: #{err}"
      end
    end
  end

  def self.import_finRpt_one(stock)
    records = []
    if stock.stamp == "us"
      records = import_us_finRpt stock
    else
      #records = import_hk_finRpt s
      records = import_hk_finRpt_from_tonghuashun stock
    end

    return Runlog::STATUS_DISABLE if records.blank?
    puts "import_finRpt_one #{stock.code}"

    exists = {}
    FinReport.where(fd_code:stock.code).all.each do |r|
      uk = "#{r.fd_code},#{r.fd_year},#{r.fd_type}"
      exists[uk] = r
    end

    FinReport.transaction do
      records.each do |item|
        if item[:fd_year].to_i < 2010 || item[:fd_type].blank?
          #puts "ignore fd_year<2010: " + item.inspect
          next
        end
        begin
          uk = "#{item[:fd_code]},#{item[:fd_year]},#{item[:fd_type]}"
          if exists[uk]
            exists[uk].update_attributes item
          else
            FinReport.create item
          end
        rescue => err
          puts err
        end
      end
    end

    Runlog::STATUS_OK
  end

=begin
    从同花顺抓取 美股 财务数据
    http://stockpage.10jqka.com.cn/WB/finance/
    资产负债表：
    <p id="debt">{"title":["鏃堕棿\\绉戠洰",["总现金","万美元"],["其中：现金与现金等价物","万美元"],["短期投资","万美元"],["应收账款","万美元"],["存货","万美元"],["预付款项","万美元"],["流动资产特殊项目","万美元"],["流动资产合计","万美元"],["固定资产净额","万美元"],["净无形资产","万美元"],["股权投资和长期投资","万美元"],["非流动资产递延所得税","万美元"],["非流动资产特殊项目","万美元"],["非流动资产合计","万美元"],["资产合计","万美元"],["应付账款","万美元"],["应交税费","万美元"],["应付负债","万美元"],["流动负债延递收入","万美元"],["流动负债合计","万美元"],["递延所得税负债","万美元"],["非流动负债递延收入","万美元"],["非流动负债特殊项目","万美元"],["非流动负债合计","万美元"],["负债合计","万美元"],["普通股","万美元"],["其中：库存股","万美元"],["归属于母公司股东权益合计","万美元"],["归属于少数股东权益","万美元"],["股东权益合计","万美元"]],"report":[["2016-12-31<br>2016年年报","2016-06-30<br>2016年中报","2015-12-31<br>2015年年报","2015-09-30<br>2015年三季报(累计)"]]}

    现金与现金等价物 idx2,单位：万元/万美元
    股东权益合计: idx-1，单位：万元/万美元
    非流动负债合计：idx-5，单位：万元/万美元
    流动负债合计:idx-7，单位：万元/万美元
    流动资产合计:idx7，单位：万元/万美元

    主要指标：
    <p id="keyindex">{"title":["鏃堕棿\\绉戠洰",["基本每股收益 ","美元"],["稀释每股收益","美元"],["每股净资产","美元"],["每股现金流","美元"],["每股营业收入","美元"],["营业周期","天"],["存货周转天数","天"],["存货周转率","次"],["应收账款周转天数","天"],["应收账款周转率","次"],["流动资产周转率","次"],["固定资产周转率","次"],["总资产周转率","次"],["相对年初每股净资产增长率","%"],["相对年初资产总计增长率","%"],["相对年初归属母公司的股东权益增长率","%"],["流动比率",""],["速动比率",""],["产权比率","%"],["归属母公司股东的权益\/负债合计","%"]],"report":[["2016-12-31<br>2016年年报","2016-06-30<br>2016年中报","2015-12-31<br>2015年年报","2015-09-30<br>2015年三季报(累计)"]]}

    基本每股收益:idx-2,fd_profit_base_share，单位：元/美元
    稀释每股收益:idx-1

=end
  def self.import_us_finRpt stock
    regexp = /([A-Z]+)/
    md = stock.code.match(regexp)
    return [] unless md

    code = md[1]
    url = "http://stockpage.10jqka.com.cn/#{code}/finance/"
    rsp = Net::HTTP.get(URI.parse(url))
    regexp = /<p id="keyindex">(.*)<\/p>/
    match_data = rsp.match(regexp)
    return [] unless match_data

    json_str = match_data[1]
    keyindex_json = ActiveSupport::JSON.decode(json_str)
    keyindex_report = keyindex_json["report"]

    regexp = /<p id="debt">(.*)<\/p>/
    match_data = rsp.match(regexp)
    return [] unless match_data

    debt_json_str = match_data[1]
    debt_json = ActiveSupport::JSON.decode(debt_json_str)
    debt_report = debt_json["report"]
    
    regexp = /<p id="cash">(.*)<\/p>/
    match_data = rsp.match(regexp)
    return [] unless match_data

    cash_json_str = match_data[1]
    cash_json = ActiveSupport::JSON.decode(cash_json_str)
    cash_report = cash_json["report"]

    records = []
    cols = []
    # fd_year, fd_type
    # "2016-06-30<br>2016\u5e74\u4e2d\u62a5"
    currency = CURRENCY_USD
    keyindex_json["title"][1..-1].each do |arr|
      if arr[1] == "元"
        currency = CURRENCY_CNY
        break
      elsif arr[1] == "美元"
        currency = CURRENCY_USD
        break
      end
    end

    keyindex_report[0].each_with_index  do |cell,idx|
      unless cell.to_s.match(/^20[012][0-9]/)
        next
      end

      fd_repdate, fd_year_msg = cell.split("<br>")
      if fd_year_msg.end_with? "一季报"
        fd_type = FinReport::TYPE_Q1
      elsif fd_year_msg.end_with? "中报"
        fd_type = FinReport::TYPE_SUM_Q2
      elsif fd_year_msg.end_with? "三季报(累计)"
        fd_type = FinReport::TYPE_SUM_Q3
      elsif fd_year_msg.end_with? "年报"
        fd_type = FinReport::TYPE_ANNUAL
      else
        next
      end

      fd_year = fd_year_msg.match(/(\d+)/)[1]
      cols << idx
      records << {fd_code:stock.code, fd_year:fd_year, fd_repdate:fd_repdate, fd_type:fd_type, currency:currency}
    end

    # 计算行
    keyindex_row_title = keyindex_json["title"][1..-1].map{|arr| arr[0].strip}
    keyindex_row_label = {fd_profit_base_share:"基本每股收益"}

    debt_row_title = debt_json["title"][1..-1].map{|arr| arr[0].strip}
    debt_row_label = {fd_cash_and_deposit:["其中：现金与现金等价物","现金和现金等价物","现金和中央银行存款"],fd_stkholder_rights:"股东权益合计",fd_non_liquid_debts:["非流动负债合计","长期债务"],fd_liquid_debts:["流动负债合计","短期借款"],fd_liquid_assets:"流动资产合计"}

    cash_row_title = cash_json["title"][1..-1].map{|arr| arr[0].strip}
    cash_row_label = {operating_cash:["经营活动现金流量净额","经营活动产生的现金流量净额"],invest_cash:["投资活动现金流量净额","投资活动产生的现金流量净额"],loan_cash:["筹资活动现金流量净额","筹资活动产生的现金流量净额"]}

    keyindex_row_idx = calc_row_idx keyindex_row_label,keyindex_row_title,stock.code
    debt_row_idx = calc_row_idx debt_row_label,debt_row_title,stock.code
    cash_row_idx = calc_row_idx cash_row_label,cash_row_title,stock.code

    # 填充表格
    cols.each_with_index do |col,idx|
      keyindex_row_idx.each do |field,row|
        records[idx][field] = keyindex_report[row][col]
      end

      debt_row_idx.each do |field,row|
        records[idx][field] = debt_report[row][col]
      end

      cash_row_idx.each do |field,row|
        records[idx][field] = cash_report[row][col]
      end
    end

    records
  end

  # 从同花顺抓取
  # http://stockpage.10jqka.com.cn/HK0700/finance/
  # 港股的财报：3月底:Q1，6月底：SUM_Q2，9月底：SUM_Q3，12月底：年报，像长城汽车就只有 SUM_Q2 和 年报

  # 重要指标
  # <p id="keyindex">{"title":["鏃堕棿\\绉戠洰",["基本每股收益 ","元"],["稀释每股收益","元"],["净利润","万元"],["净利润同比增长率","%"],["营业额","万元"],["营业额同比增长率","%"],["每股营业总收入","元"],["每股净资产","元"],["净资产收益率","%"],["资产负债率","%"],["每股公积金","元"],["每股股息","元"],["每股现金流","元"],["主营利润率","%"]],"report":[["2017-03-31","2016-12-31","2016-09-30"],[]]}
  # 基本每股收益 (元)
  # 稀释每股收益(元)

  # 资产负债表
  # <p id="debt">{"title":["鏃堕棿\\绉戠洰",["资产合计","万元"],["负债合计","万元"],["权益合计","万元"],["不动产、厂房和设备","万元"],["存货","万元"],["应收账款","万元"],["交易性金融资产","万元"],["现金及现金等价物","万元"],["流动资产合计","万元"],["应付账款","万元"],["应交税费","万元"],["流动负债合计","万元"],["非流动负债合计","万元"],["归属于母公司股东权益","万元"]],"report":["2017-03-31","2016-12-31","2016-09-30"],[]]}
  # 现金及现金等价物(万元)
  # 流动资产合计(万元)
  # 流动负债合计(万元)
  # 非流动负债合计(万元)
  # 权益合计(万元)
  def self.import_hk_finRpt_from_tonghuashun stock
    # hk00700 => HK0700
    code = stock.code.sub /hk0/i, "HK"
    url = "http://stockpage.10jqka.com.cn/#{code}/finance/"
    rsp = Net::HTTP.get(URI.parse(url))
    regexp = /<p id="keyindex">(.*)<\/p>/
    match_data = rsp.match(regexp)
    return [] unless match_data

    json_str = match_data[1]
    keyindex_json = ActiveSupport::JSON.decode(json_str)
    keyindex_report = keyindex_json["report"]

    regexp = /<p id="debt">(.*)<\/p>/
    match_data = rsp.match(regexp)
    return [] unless match_data

    debt_json_str = match_data[1]
    debt_json = ActiveSupport::JSON.decode(debt_json_str)
    debt_report = debt_json["report"]

    regexp = /<p id="cash">(.*)<\/p>/
    match_data = rsp.match(regexp)
    return [] unless match_data

    cash_json_str = match_data[1]
    cash_json = ActiveSupport::JSON.decode(cash_json_str)
    cash_report = cash_json["report"]

    records = []
    cols = []
    # fd_year, fd_type
    # 计算财年
    currency = CURRENCY_HKD
    keyindex_json["title"][1..-1].each do |arr|
      if arr[1] == "元"
        currency = CURRENCY_CNY
        break
      elsif arr[1] == "港元"
        currency = CURRENCY_HKD
        break
      end
    end

    keyindex_report[0].each_with_index  do |cell,idx|
      unless cell.to_s.match(/^20[1-9][0-9]/)
        next
      end

      fd_repdate = Date.strptime(cell, '%Y-%m-%d')
      case fd_repdate.month
        when 3
          fd_type = TYPE_Q1
        when 6
          fd_type = TYPE_SUM_Q2
        when 9
          fd_type = TYPE_SUM_Q3
        when 12
          fd_type = TYPE_ANNUAL
        else
          puts "invalid repdate of #{stock.code}: #{fd_repdate}"
          next
      end

      fd_year = fd_repdate.year
      cols << idx
      records << {fd_code:stock.code, fd_year:fd_year, fd_repdate:fd_repdate, fd_type:fd_type, currency:currency}
    end

    # 计算行
    keyindex_row_title = keyindex_json["title"][1..-1].map do |arr|
      arr[0].strip
    end
    keyindex_row_label = {fd_profit_base_share:"基本每股收益",fd_profit_after_share:"稀释每股收益"}

    debt_row_title = debt_json["title"][1..-1].map do |arr|
      arr[0].strip
    end
    debt_row_label = {fd_cash_and_deposit:"现金及现金等价物",fd_stkholder_rights:"权益合计",fd_non_liquid_debts:"非流动负债合计",fd_liquid_debts:"流动负债合计",fd_liquid_assets:"流动资产合计"}

    cash_row_title = cash_json["title"][1..-1].map{|arr| arr[0].strip}
    cash_row_label = {operating_cash:"经营流动现金流量净额",invest_cash:"投资活动现金流量净额",loan_cash:"融资活动现金流量净额"}

    keyindex_row_idx = calc_row_idx keyindex_row_label,keyindex_row_title, stock.code
    debt_row_idx = calc_row_idx debt_row_label,debt_row_title, stock.code
    cash_row_idx = calc_row_idx cash_row_label,cash_row_title,stock.code

    # 填充表格
    cols.each_with_index do |col,idx|
      keyindex_row_idx.each do |field,row|
        records[idx][field] = keyindex_report[row][col]
      end

      debt_row_idx.each do |field,row|
        records[idx][field] = debt_report[row][col]
      end

      cash_row_idx.each do |field,row|
        records[idx][field] = cash_report[row][col]
      end
    end

    records
  end

  def self.calc_row_idx(cash_row_label,cash_row_title, code)
    cash_row_idx = {}
    cash_row_label.each do |k,v|
      idx = nil
      if v.is_a? Array
        v.each do |e|
          idx = cash_row_title.index(e)
          break if idx
        end
      else
        idx = cash_row_title.index(v)
      end
      unless idx
        puts "cant find #{v} from labels of #{code}"
        next
      end

      cash_row_idx[k] = idx + 1
    end

    cash_row_idx
  end

=begin
  港股
  综合损益表：http://web.ifzq.gtimg.cn/appstock/hk/HkInfo/getFinReport?type=3&reporttime_type=-1&code=00700&&startyear=2015&endyear=2016
  基本每股盈利:fd_profit_base_share，单元：元，港币/人民币
  每股股息：fd_dividend_base_share，单元：元，港币/人民币

  资产负债表：http://web.ifzq.gtimg.cn/appstock/hk/HkInfo/getFinReport?type=1&reporttime_type=-1&code=00700&&startyear=2015&endyear=2016
  非流动负债: fd_non_liquid_debts，单位：百万
  股东权益: fd_stkholder_rights，单位：百万

  流动负债:fd_liquid_debts，单位：百万
  流动资产: fd_liquid_assets，单位：百万

  现金及银行结存:fd_cash_and_bankdeposit，单位：百万

  d_type=1, 年报
  3 Q2
  4,Q1
  2，Q3
=end
  def self.import_hk_finRpt stock
    code = stock.code.match(/(\d+)/)[1]
    url = "http://web.ifzq.gtimg.cn/appstock/hk/HkInfo/getFinReport?type=3&reporttime_type=-1&code=#{code}&&startyear=2010&endyear=#{Time.now.year}"
    rsp = Net::HTTP.get(URI.parse(url))
    json_str = rsp
    benefit_json = ActiveSupport::JSON.decode(json_str)
    benefit_items = benefit_json["data"]["data"]

    url = "http://web.ifzq.gtimg.cn/appstock/hk/HkInfo/getFinReport?type=1&reporttime_type=-1&code=#{code}&&startyear=2010&endyear=#{Time.now.year}"
    rsp = Net::HTTP.get(URI.parse(url))
    json_str = rsp
    debit_json = ActiveSupport::JSON.decode(json_str)
    debit_items = debit_json["data"]["data"]

    records = {}
    benefit_items.each do |item|
      uk = "#{item["fd_code"]},#{item["fd_year"]},#{item["fd_type"]}"
      record = {fd_code:stock.code, fd_year:item["fd_year"], fd_repdate:item["fd_repdate"], fd_type:item["fd_type"],
       fd_turnover:item["fd_turnover"],fd_profit_base_share:item["fd_profit_base_share"],fd_profit_after_share:item["fd_profit_after_share"],
                  fd_dividend_base_share:item["fd_dividend_base_share"]
      }

      records[uk] = record
    end

    debit_items.each do |item|
      uk = "#{item["fd_code"]},#{item["fd_year"]},#{item["fd_type"]}"
      record = records[uk]
      unless record
        record = {fd_code:stock.code, fd_year:item["fd_year"], fd_repdate:item["fd_repdate"], fd_type:item["fd_type"]}
        puts "#{uk} cant found in benefit report: #{records.keys}"
      end

      #:fd_dividend_base_share, :fd_non_liquid_debts, :fd_stkholder_rights,
      #:fd_liquid_debts, :fd_liquid_assets, :fd_cash_and_deposit
      record[:fd_non_liquid_debts] = item["fd_non_liquid_debts"]
      record[:fd_stkholder_rights] = item["fd_stkholder_rights"]
      record[:fd_liquid_debts] = item["fd_liquid_debts"]
      record[:fd_liquid_assets] = item["fd_liquid_assets"]
      record[:fd_cash_and_deposit] = item["fd_cash_and_bankdeposit"]
    end
    records.values
  end

  def self.filter_by_operating_cash_of_q_matrix(stocks)
    filter_stocks = []
    stocks.each do |stock|
      fin_reports = FinReport.where(fd_code:stock.code).order("fd_repdate desc").limit(8).all
      q_matrix_meta = q_matrix_with_meta stock, fin_reports

      up_cnt = 0
      cnt = 0
      q_matrix_meta[:idx][0..-1].each do |e|
        uk = "#{e[0]},#{e[1]}"
        prev_year = e[0].to_i - 1
        prev_year_uk = "#{prev_year},#{e[1]}"

        if q_matrix_meta[:operating_cash][uk] && q_matrix_meta[:operating_cash][prev_year_uk]
          if q_matrix_meta[:operating_cash][uk] > q_matrix_meta[:operating_cash][prev_year_uk]
            up_cnt += 1
          end
        end

        cnt += 1
        break if cnt>=4
      end

      filter_stocks << stock if up_cnt >=3
    end

    filter_stocks
  end

  # 计算年报数据
  def self.fy_matrix stock,fin_reports
    dest_currency = stock.stamp=='us' ? FinReport::CURRENCY_USD : FinReport::CURRENCY_HKD
    currency = nil

    # 计算年报
    fy_matrix = {fd_year:[],fd_price:[],fd_profit_base_share:[],fd_cash_base_share:[],fd_debt_rate:[],fd_virtual_profit_base_share:[],
                 pe:[],up_rate_of_profit:[]}
    klines = Dayline.where("code='#{stock.code}'").order("day desc").select("day,close").all

    fin_reports.each do |r|
      next if r.fd_type != FinReport::TYPE_ANNUAL

      currency = r.currency
      fy_matrix[:fd_year] << r.fd_year
      fy_matrix[:fd_price] << close_price(klines,r.fd_repdate.to_date)
      fy_matrix[:fd_profit_base_share] << currency_translate(r.fd_profit_base_share,currency,dest_currency)
      fy_matrix[:fd_cash_base_share] << currency_translate(cash_base_share(stock.gb,r.fd_cash_and_deposit),currency,dest_currency)
      fy_matrix[:fd_debt_rate] << stkholder_rights_of_debt(r.fd_non_liquid_debts,r.fd_stkholder_rights)
    end

    fy_matrix[:fd_profit_base_share].each_with_index do |e,idx|
      rate = if e && fy_matrix[:fd_profit_base_share][idx+1]
               ((e - fy_matrix[:fd_profit_base_share][idx+1]) * 100/ fy_matrix[:fd_profit_base_share][idx+1]).round(2)
             else
               nil
             end

      fy_matrix[:up_rate_of_profit] << rate
    end

    fy_matrix[:fd_price].each_with_index do |p,idx|
      pe = if p && fy_matrix[:fd_profit_base_share][idx] && fy_matrix[:fd_profit_base_share][idx]>0
             ((p)/ fy_matrix[:fd_profit_base_share][idx]).round(2)
           else
             nil
           end

      fy_matrix[:pe] << pe
    end

    fy_matrix
  end

  # 计算季报
  def self.q_matrix(stock,fin_reports)
    dest_currency = stock.stamp=='us' ? FinReport::CURRENCY_USD : FinReport::CURRENCY_HKD
    currency = nil

    q_matrix = {fd_repdate:[],fd_price:[],fd_profit_base_share:[],fd_cash_base_share:[],fd_debt_rate:[],fd_rights_rate:[],
                operating_cash:[],invest_cash:[],loan_cash:[],up_rate_of_profit:[],sum_profit_of_lastyear:[],pe:[]}
    cnt = 0
    q_matrix_meta = {idx:[],profit_base_share:{},operating_cash:{}}
    klines = Dayline.where("code='#{stock.code}'").order("day desc").select("day,close").all
    fin_reports.each do |r|
      currency = r.currency
      q_matrix[:fd_repdate] << "#{r.fd_repdate.strftime '%Y%m%d'}<br/>#{fin_report_label r.fd_type}"
      q_matrix[:fd_price] << close_price(klines,r.fd_repdate.to_date)
      q_matrix[:fd_profit_base_share] << currency_translate(r.fd_profit_base_share,currency,dest_currency)
      q_matrix[:fd_cash_base_share] << currency_translate(cash_base_share(stock.gb,r.fd_cash_and_deposit),currency,dest_currency)
      q_matrix[:fd_rights_rate] << stkholder_rights_of_debt(r.fd_non_liquid_debts,r.fd_stkholder_rights)
      q_matrix[:fd_debt_rate] << debt_rate_of_asset(r.fd_liquid_assets,r.fd_liquid_debts)
      q_matrix[:operating_cash] << currency_translate(cash_base_share(stock.gb,r.operating_cash),currency,dest_currency)
      q_matrix[:invest_cash] << currency_translate(cash_base_share(stock.gb,r.invest_cash),currency,dest_currency)
      q_matrix[:loan_cash] << currency_translate(cash_base_share(stock.gb,r.loan_cash),currency,dest_currency)

      q_matrix_meta[:operating_cash]["#{r.fd_year},#{r.fd_type}"] = q_matrix[:operating_cash].last
      q_matrix_meta[:profit_base_share]["#{r.fd_year},#{r.fd_type}"] = r.fd_profit_base_share
      q_matrix_meta[:idx] << [r.fd_year,r.fd_type]

      cnt += 1
      break if cnt > 12
    end

    q_matrix_meta[:idx][0..-1].each do |e|
      uk = "#{e[0]},#{e[1]}"
      prev_year = e[0].to_i - 1
      prev_year_uk = "#{prev_year},#{e[1]}"
      rate = if q_matrix_meta[:profit_base_share][uk] && q_matrix_meta[:profit_base_share][prev_year_uk]  && q_matrix_meta[:profit_base_share][prev_year_uk]>0
               ((q_matrix_meta[:profit_base_share][uk] - q_matrix_meta[:profit_base_share][prev_year_uk]) * 100/ q_matrix_meta[:profit_base_share][prev_year_uk]).round(2)
             else
               nil
             end
      q_matrix[:up_rate_of_profit] << rate

      prev_fy_uk = "#{prev_year},#{FinReport::TYPE_ANNUAL}"
      v = if q_matrix_meta[:profit_base_share][uk] && q_matrix_meta[:profit_base_share][prev_fy_uk] && q_matrix_meta[:profit_base_share][prev_year_uk]
            (q_matrix_meta[:profit_base_share][uk] + (q_matrix_meta[:profit_base_share][prev_fy_uk] - q_matrix_meta[:profit_base_share][prev_year_uk])).round(2)
          else
            nil
          end
      q_matrix[:sum_profit_of_lastyear] << currency_translate(v,currency,dest_currency)
    end

    q_matrix[:fd_price].each_with_index do |p,idx|
      pe = if p && q_matrix[:sum_profit_of_lastyear][idx] && q_matrix[:sum_profit_of_lastyear][idx]>0
             ((p)/ q_matrix[:sum_profit_of_lastyear][idx]).round(2)
           else
             nil
           end

      q_matrix[:pe] << pe
    end

    q_matrix
  end

  def self.close_price(klines, day)
    r = nil
    klines.each do |row|
      if row.day <= day
        r = row
        break
      end
    end

    r.nil? ? nil : r.close
  end

  # 获取季报及坐标
  def self.q_matrix_with_meta(stock,fin_reports)
    dest_currency = stock.stamp=='us' ? FinReport::CURRENCY_USD : FinReport::CURRENCY_HKD
    cnt = 0
    q_matrix_meta = {idx:[],profit_base_share:{},operating_cash:{}}
    fin_reports.each do |r|
      currency = r.currency
      q_matrix_meta[:operating_cash]["#{r.fd_year},#{r.fd_type}"] = currency_translate(cash_base_share(stock.gb,r.operating_cash),currency,dest_currency)
      q_matrix_meta[:idx] << [r.fd_year,r.fd_type]

      cnt += 1
      break if cnt > 12
    end

    q_matrix_meta
  end
  def self.cash_base_share(gb, cash)
    return 0 if cash.nil? or gb.nil?
    (gb>1 ? (cash *  FinReport::FIN_RPT_UNIT / gb).round(2) : 0)
  end

  def self.stkholder_rights_of_debt(fd_non_liquid_debts,fd_stkholder_rights)
    unless fd_non_liquid_debts && fd_stkholder_rights
      return nil
    end

    total = fd_non_liquid_debts + fd_stkholder_rights
    if total < 0.001
      0
    else
      (fd_stkholder_rights / total).round(4)
    end
  end

  def self.debt_rate_of_asset(fd_non_liquid_debts,fd_stkholder_rights)
    unless fd_non_liquid_debts && fd_stkholder_rights
      return nil
    end

    total = fd_non_liquid_debts + fd_stkholder_rights
    if total < 0.001
      0
    else
      (fd_stkholder_rights / total).round(4)
    end
  end

  def self.currency_translate(arr,src_currency,dest_currency)
    if src_currency == dest_currency
      arr
    elsif src_currency == FinReport::CURRENCY_CNY && dest_currency == FinReport::CURRENCY_USD
      if arr.is_a? Array
        arr.map {|e| e.nil? ? e : (e * FinReport::CNY2USD_RATE).round(3)}
      else
        e = arr
        e.nil? ? e : (e * FinReport::CNY2USD_RATE).round(3)
      end
    elsif src_currency == FinReport::CURRENCY_CNY && dest_currency == FinReport::CURRENCY_HKD
      if arr.is_a? Array
        arr.map {|e| e.nil? ? e : (e * FinReport::CNY2HKD_RATE).round(3)}
      else
        e = arr
        e.nil? ? e : (e * FinReport::CNY2HKD_RATE).round(3)
      end
    elsif src_currency == FinReport::CURRENCY_USD && dest_currency == FinReport::CURRENCY_HKD
      if arr.is_a? Array
        arr.map {|e| e.nil? ? e : (e * FinReport::USD2HKD_RATE).round(3)}
      else
        e = arr
        e.nil? ? e : (e * FinReport::USD2HKD_RATE).round(3)
      end
    else
      logger.error "invalid currency translate: from #{src_currency} to #{dest_currency}"
      arr
    end
  end

  def self.fin_report_label(type)
    case type
      when FinReport::TYPE_Q1
        "Q1"
      when FinReport::TYPE_Q2
        "Q2"
      when FinReport::TYPE_Q3
        "Q3"
      when FinReport::TYPE_ANNUAL
        "FY"
      when FinReport::TYPE_SUM_Q2
        "SUM_Q2"
      when FinReport::TYPE_SUM_Q3
        "SUM_Q3"
      else
        "invalid"
    end
  end
end
