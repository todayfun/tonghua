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
        "(连续上涨)#{stock.weekrise}"
      when 2
        "(跌后反弹)#{stock.weekrise}"
      when 3
        "(超跌反弹)#{stock.weekrise}"
      when 4
        "(反弹上涨)#{stock.weekrise}"
      else
        ""
    end
  end
end
