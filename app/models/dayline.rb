class Dayline < ActiveRecord::Base
  attr_accessible :close, :code, :day, :high, :low, :open, :vol

  def self.import
    stocks = Stock.all
    ignored_codes = Runlog.ignored Runlog::NAME_DAYLINE,[Runlog::STATUS_DISABLE,Runlog::STATUS_IGNORE],1.day.ago
    new_imported = 0
    stocks.each do |stock|
      begin
        next if ignored_codes.include?(stock.code)
        lastest_day = Dayline.where(code:stock.code).select("day").order("day desc").limit(1).first.try :day
        lastest_day ||= Date.parse("2010-01-01")

        end_date = Date.today.end_of_year
        begin_date = (lastest_day.year==end_date.year) ? lastest_day : end_date.beginning_of_year

        while true
          status = import_dayline stock.code, stock.stamp, begin_date, end_date
          begin_date = begin_date.prev_year
          end_date = end_date.prev_year

          break if begin_date.year < lastest_day.year
          break if status == Runlog::STATUS_IGNORE
        end

        Runlog.update_log stock.code,Runlog::NAME_DAYLINE,status
        new_imported += 1
      rescue => err
        puts "import dayline exception for #{stock.code}: #{err}"
      end
    end

    total_imported = Dayline.count("distinct code")
    total_stotck = Stock.count("distinct code")
    puts "new import dayline: #{new_imported}, total imported: #{total_imported}, total stock: #{total_stotck}"
  end

  # http://web.ifzq.gtimg.cn/appstock/app/hkfqkline/get?param=hk00700,day,2015-01-01,2016-12-31,320,qfq
  def self.import_dayline(code,stamp,begin_date,end_date)
    url = nil
    case stamp
      when "us"
        url="http://web.ifzq.gtimg.cn/appstock/app/usfqkline/get?param=#{code},day,#{begin_date.strftime("%Y-%m-%d")},#{end_date.strftime("%Y-%m-%d")},320,qfq"
      when "hk"
        url="http://web.ifzq.gtimg.cn/appstock/app/hkfqkline/get?param=#{code},day,#{begin_date.strftime("%Y-%m-%d")},#{end_date.strftime("%Y-%m-%d")},320,qfq"
      else

    end

    if url.nil?
      return Runlog::STATUS_DISABLE
    end

    puts "import dayline #{code} from #{begin_date} to #{end_date}"
    rsp = Net::HTTP.get(URI.parse(url))

    parsed_json = ActiveSupport::JSON.decode(rsp)["data"]
    return Runlog::STATUS_DISABLE if parsed_json.nil? || !parsed_json.is_a?(Hash)

    parsed_json = parsed_json[code]
    raw_deals = parsed_json["qfqday"] || parsed_json["day"]

    if raw_deals.nil?
      puts "#{code} dayline nil"
      return Runlog::STATUS_DISABLE
    end

    return Runlog::STATUS_IGNORE if raw_deals.blank?

    raw_deals = raw_deals.sort do |a,b|
      b[0] <=> a[0]
    end

    Dayline.transaction do
      raw_deals.each do |r|
        begin
          Dayline.create code:code,day:r[0],open:r[1],close:r[2],high:r[3],low:r[4],vol:r[5]
            # catch SQLite3::ConstraintException: UNIQUE constraint failed
        rescue ActiveRecord::StatementInvalid
          break
        end
      end
    end

    Runlog::STATUS_OK
  end
end
