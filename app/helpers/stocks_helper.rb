module StocksHelper
  def stockurl(code, stamp)
    if stamp=="us"
      "http://gu.qq.com/#{code}/gg"
    else
      "http://gu.qq.com/#{code}/gp"
    end
  end

  def riselabel(weekrise)
    case weekrise
      when 1
        "(连续上涨)"
      when 2
        "(超跌反弹)"
      when 3
        "(反弹上涨)"
      else
        ""
    end
  end
end
