class Monthline < ActiveRecord::Base
  attr_accessible :close, :code, :day, :high, :low, :open, :vol

  def self.import
    onemonthago_day = Time.now.beginning_of_month.strftime('%Y-%m-%d')
    imported_codes = Monthline.where("`day`>\"#{onemonthago_day}\"").select("distinct `code`").map &:code

    stocks = Stock.all
    ignored_codes = Runlog.ignored Runlog::NAME_MONTHLINE,[Runlog::STATUS_DISABLE,Runlog::STATUS_IGNORE],1.month.ago
    new_imported = 0
    stocks.each do |stock|
      unless imported_codes.include? stock.code
        begin
          next if ignored_codes.include?(stock.code)

          status = import_monthline stock.code, stock.stamp

          Runlog.update_log stock.code,Runlog::NAME_MONTHLINE,status
          new_imported += 1
        rescue => err
          puts "import_monthline exception for #{stock.code}: #{err}"
        end
      end
    end

    total_imported = Monthline.count("distinct code")
    total_stotck = Stock.count("distinct code")
    puts "new import monthline: #{new_imported}, total imported: #{total_imported}, total stock: #{total_stotck}"
  end

  def self.import_monthline(code,stamp)
    url = nil
    case stamp
      when "us"
        url="http://web.ifzq.gtimg.cn/appstock/app/usfqkline/get?param=#{code},month,,,320,qfq"
      when "hk"
        url="http://web.ifzq.gtimg.cn/appstock/app/hkfqkline/get?param=#{code},month,,,320,qfq"
      else

    end

    if url.nil?
      return Runlog::STATUS_DISABLE
    end

    puts "import monthline #{code}"
    rsp = Net::HTTP.get(URI.parse(url))

    parsed_json = ActiveSupport::JSON.decode(rsp)["data"]
    return Runlog::STATUS_DISABLE if parsed_json.nil? || !parsed_json.is_a?(Hash)

    parsed_json = parsed_json[code]
    raw_deals = parsed_json["qfqmonth"] || parsed_json["month"]

    if raw_deals.nil?
      puts "#{code} monthline nil"
      return Runlog::STATUS_DISABLE
    end

    raw_deals = raw_deals.sort do |a,b|
      b[0] <=> a[0]
    end

    lastoneyear_deals = []
    oneyearago_day = "2009-12-31"
    raw_deals.each do |r|
      if r[0] < oneyearago_day
        break
      else
        lastoneyear_deals << r
      end
    end

    return Runlog::STATUS_IGNORE if lastoneyear_deals.blank?

    # 第一条记录很可能不是月K
    obj = Monthline.where(code:code).order("day desc").first
    obj.delete if obj

    Monthline.transaction do
      lastoneyear_deals.each do |r|
        begin
          Monthline.create code:code,day:r[0],open:r[1],close:r[2],high:r[3],low:r[4],vol:r[5]
            # catch SQLite3::ConstraintException: UNIQUE constraint failed
        rescue ActiveRecord::StatementInvalid
          break
        end
      end
    end

    Runlog::STATUS_OK
  end

  # 查看过去两年的走势
  def self.rise_trend(code,cnt)
    deals = Monthline.where("code=\"#{code}\"").order("day desc").limit(cnt+1)
    if deals.size < cnt+1
      return false
    end

    arr_up = []
    arr_down = []
    deals[0...cnt].each_index do |idx|
      if deals[idx].close > deals[idx].open
        arr_up << (deals[idx].open+deals[idx].close) * deals[idx].vol
      else
        arr_down << (deals[idx].open+deals[idx].close) * deals[idx].vol
      end
    end

    rise_rate = 0
    if (arr_up.size > arr_down.size)
      if arr_down.sum > 0
        rise_rate = arr_up.sum / arr_down.sum
      else
        rise_rate = arr_up.size
      end
    end

    rise_rate
  end
end
