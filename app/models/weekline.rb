class Weekline < ActiveRecord::Base
  attr_accessible :close, :code, :day, :high, :low, :open, :vol

  def self.import
    stocks = Stock.all
    stocks.each do |stock|
      import_weekline stock.code,stock.stamp
    end
  end

  def self.import_weekline(code,stamp)
    url = nil
    case stamp
      when "us"
        url="http://web.ifzq.gtimg.cn/appstock/app/usfqkline/get?_var=kline_weekqfq&param=#{code},week,,,320,qfq"
      when "hk"
        url="http://web.ifzq.gtimg.cn/appstock/app/hkfqkline/get?_var=kline_weekqfq&param=#{code},week,,,320,qfq"
      else

    end

    if url.nil?
      return
    end

    rsp = Net::HTTP.get(URI.parse(url))
    json_str = rsp.split('=').last

    raw_deals = ActiveSupport::JSON.decode(json_str)["data"][code]["qfqweek"]
    if raw_deals.nil?
      puts "#{code} weekline nil"
      return
    end

    Weekline.transaction do
      raw_deals.each do |r|
        begin
        Weekline.create code:code,day:r[0],open:r[1],close:r[2],high:r[3],low:r[4],vol:r[5]
          # catch SQLite3::ConstraintException: UNIQUE constraint failed
        rescue ActiveRecord::StatementInvalid
        end
      end
    end
  end
end