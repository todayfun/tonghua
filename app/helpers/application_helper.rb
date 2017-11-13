module ApplicationHelper
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

  def highchart_line(title,categories,series,min=nil,max=nil)
    chart = LazyHighCharts::HighChart.new('graph') do |f|
      f.title(text: title)
      f.chart(width:"650",height:"300")
      f.xAxis(categories: categories)
      f.yAxis(min:min) if min
      f.yAxis(max:max) if max
      f.legend(layout:"vertical",align:"right",verticalAlign:"middle")

      series.each do |name,data|
        f.series name:name,data:data
      end
    end

    chart
  end
end
