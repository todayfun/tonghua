module ApplicationHelper
  def fin_report_label(type)
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

  def cash_base_share(stock_type, gb, cash)
    return 0 if cash.nil? or gb.nil?
    (gb>1 ? (cash *  FinReport::FIN_RPT_UNIT / gb).round(2) : 0)
  end

  def stkholder_rights_of_debt(fd_non_liquid_debts,fd_stkholder_rights)
    total = fd_non_liquid_debts + fd_stkholder_rights
    if total < 0.001
      0
    else
      (fd_stkholder_rights / total).round(4)
    end
  end

  # http://stockpage.10jqka.com.cn/WB/finance/
  # http://stockpage.10jqka.com.cn/HK0700/finance/
  def link_to_tonghuashun_finance(stock)
    if stock.stamp == 'us'
      regexp = /([A-Z]+)/
      code = stock.code.match(regexp)[1]
      "http://stockpage.10jqka.com.cn/#{code}/finance/"
    else
      code = stock.code.sub /hk0/i, "HK"
      "http://stockpage.10jqka.com.cn/#{code}/finance/"
    end
  end

  def currency_translate(arr,src_currency,dest_currency)
    if src_currency == dest_currency
      arr
    elsif src_currency == FinReport::CURRENCY_CNY && dest_currency == FinReport::CURRENCY_USD
      arr.map {|e| e.nil? ? e : e * FinReport::CNY2USD_RATE}
    elsif src_currency == FinReport::CURRENCY_CNY && dest_currency == FinReport::CURRENCY_HKD
      arr.map {|e| e.nil? ? e : e * FinReport::CNY2HKD_RATE}
    else
      logger.error "invalid currency translate: from #{src_currency} to #{dest_currency}"
    end
  end
end
