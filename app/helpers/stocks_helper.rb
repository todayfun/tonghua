module StocksHelper
  def stockurl(code, stamp)
    if stamp=="us"
      "http://gu.qq.com/#{code}/gg"
    else
      "http://gu.qq.com/#{code}/gp"
    end
  end

  def riselabel(stock)
    case stock.weekrise
      when 1
        "连续上涨#{stock.weekrise}周"
      when 2
        "跌后反弹#{stock.weekrise}周"
      when 3
        "超跌反弹#{stock.weekrise}周"
      when 4
        "反弹上涨#{stock.weekrise}周"
      else
        ""
    end
  end

  def rise_tags(stock)
    tags = (stock.good).map{|k,v| "#{k}:#{v}"};
    tags << riselabel(stock);
    tags << "净利润#{stock.rate_of_profit}%"
  end
end
