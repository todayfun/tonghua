class Weekline < ActiveRecord::Base
  attr_accessible :close, :code, :day, :high, :low, :open, :vol

  RISE_CONTINUE=1
  RISE_OVERSOLD=3
  RISE_REBOUND=4
  RISE_DOWN_AND_RISE = 2

  def self.import
    oneweekago_day = 1.week.ago.beginning_of_week.strftime('%Y-%m-%d')
    imported_codes = Weekline.where("`day`>\"#{oneweekago_day}\"").select("distinct `code`").map &:code

    stocks = Stock.all
    ignored_codes = Runlog.ignored Runlog::NAME_WEEKLINE,[Runlog::STATUS_DISABLE,Runlog::STATUS_IGNORE],1.day.ago

    new_imported = 0
    stocks.each do |stock|
      unless imported_codes.include? stock.code
        begin
          next if ignored_codes.include?(stock.code)

          status = import_weekline stock.code,stock.stamp

          Runlog.update_log stock.code,Runlog::NAME_WEEKLINE,status
          new_imported += 1
        rescue => err
          puts "import_weekline exception for #{stock.code}: #{err}"
        end
      end
    end

    total_imported = Weekline.count("distinct code")
    total_stotck = Stock.count("distinct code")
    puts "new import weekline: #{new_imported}, total imported: #{total_imported}, total stock: #{total_stotck}"
  end

  # http://web.ifzq.gtimg.cn/appstock/app/hkfqkline/get?_var=kline_weekqfq&param=hk00700,week,,,320,qfq
  def self.import_weekline(code,stamp)
    url = nil
    case stamp
      when "us"
        url="http://web.ifzq.gtimg.cn/appstock/app/usfqkline/get?param=#{code},week,,,320,qfq"
      when "hk"
        url="http://web.ifzq.gtimg.cn/appstock/app/hkfqkline/get?param=#{code},week,,,320,qfq"
      else

    end

    if url.nil?
      return Runlog::STATUS_DISABLE
    end

    puts "import weekline #{code}"
    rsp = Net::HTTP.get(URI.parse(url))
    parsed_json = ActiveSupport::JSON.decode(rsp)["data"]
    return Runlog::STATUS_DISABLE if parsed_json.nil? || !parsed_json.is_a?(Hash)

    parsed_json = parsed_json[code]
    raw_deals = parsed_json["qfqweek"] || parsed_json["week"]
    if raw_deals.nil?
      puts "#{code} weekline nil"
      return Runlog::STATUS_DISABLE
    end

    raw_deals = raw_deals.sort do |a,b|
      b[0] <=> a[0]
    end

    lastoneyear_deals = []
    oneyearago_day = 2.year.ago.strftime('%Y-%m-%d')
    raw_deals.each do |r|
      if r[0] < oneyearago_day
        break
      else
        lastoneyear_deals << r
      end
    end

    if lastoneyear_deals.first[0] > Time.now.beginning_of_week.strftime('%Y-%m-%d')
      lastoneyear_deals.shift
    end

    Weekline.transaction do
      lastoneyear_deals.each do |r|
        begin
        Weekline.create code:code,day:r[0],open:r[1],close:r[2],high:r[3],low:r[4],vol:r[5]
          # catch SQLite3::ConstraintException: UNIQUE constraint failed
        rescue ActiveRecord::StatementInvalid
        end
      end
    end

    Runlog::STATUS_OK
  end

  def self.rise_trend(code,cnt)
    deals = Weekline.where("code=\"#{code}\"").order("day desc").limit(cnt+1)
    if deals.size < cnt+1
      return 0
    end

    flg = true
    rise_cnt = 0
    deals[0...cnt].each_index do |idx|
      flg &&= deals[idx].close > deals[idx].open
      rise_cnt+=1 if deals[idx].close > deals[idx+1].close
      break unless flg
    end

    flg &&= deals[0].close > deals[1].close

    if rise_cnt==cnt && flg
      return RISE_CONTINUE
    elsif flg
      # 如果没有连续上涨，则要看回调了多少 或 反弹了多少
      close_arr = Weekline.where(code:code).order("day desc").select(:close).limit(52).map(&:close)
      max_close = close_arr.max
      min_close = close_arr.min

      # 反弹的
      return RISE_REBOUND if rise_cnt>(cnt-2)&&(deals[0].close - min_close) > min_close * 0.20

      # 超跌的
      return RISE_OVERSOLD if (max_close - deals[0].close) > max_close * 0.3
    else
      # 下跌后反弹
      rise_cnt,down_cnt = down_and_rise_trend code,6
      return RISE_DOWN_AND_RISE if rise_cnt>0 && down_cnt > 3
    end

    return 0
  end

  # 下跌后反弹
  def self.down_and_rise_trend(code,cnt)
    deals = Weekline.where("code=\"#{code}\"").select("open,close").order("day desc").limit(cnt+1)
    if deals.size < cnt+1
      return [0,0]
    end

    rise_cnt = 0
    deals[0...cnt].each_index do |idx|
      if deals[idx].close >= deals[idx+1].close && deals[idx].close>=deals[idx].open
        rise_cnt += 1
      else
        break
      end
    end

    down_cnt = 0
    deals[rise_cnt...cnt].each_index do |i|
      idx = i + rise_cnt
      if deals[idx].close <= deals[idx+1].close
        down_cnt += 1
      else
        break
      end
    end

    return [rise_cnt,down_cnt]
  end
end