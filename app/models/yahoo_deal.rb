class YahooDeal < ActiveRecord::Base
  attr_accessible :adj, :close, :code, :high, :low, :on, :open, :volume, :sig
  
  def self.query(days=100)
    codes = Gupiao.where("status <> 'NONE'").select("code").map(&:code)
    
    codes.each do |code|
      deals = {}     
      yahoo_code = code.gsub(/(sh)$/,"ss") # shanghai code to yahoo code      
      YahooFinance::get_HistoricalQuotes_days( yahoo_code, days ) do |hq|
        sig = "#{code}-#{hq.date}"
        deals[sig] = {:code=>yahoo_code,:open=>hq.open,:close=>hq.close,
          :high=>hq.high, :low=>hq.low, :volume=>hq.volume,:adj=>hq.adjClose,:on=>hq.date,:sig=>sig}
      end     
      
      exist_sigs = YahooDeal.where(:sig=>deals.keys).select("sig").map(&:sig)   
      new_deals = (deals.keys - exist_sigs).map {|sig| deals[sig]}
      YahooDeal.create new_deals          
    end    
  end  
end
