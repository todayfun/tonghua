class YahooDeal < ActiveRecord::Base
  attr_accessible :code, :deals, :judge, :trend
  
  # Getting the historical quote data as a raw array.
  # The elements of the array are:
  #   [0] - Date
  #   [1] - Open
  #   [2] - High
  #   [3] - Low
  #   [4] - Close
  #   [5] - Volume
  #   [6] - Adjusted Close
  def self.query(days=356)
    codes = Gupiao.where("status <> 'NONE'").select("code").map(&:code)
    
    codes.each do |code|
      deals = []
      yahoo_code = code.gsub(/(sh)$/,"ss") # shanghai code to yahoo code      
      YahooFinance::get_historical_quotes_days( yahoo_code, days ) do |row|
        deals << row
      end     
      
      obj = YahooDeal.find_by_code yahoo_code
      if obj
        obj.deals = deals.to_json        
      else
        obj = YahooDeal.new
        obj.code = yahoo_code
        obj.deals = deals.to_json
      end
      obj.save
      
      sleep 1.5
    end    
  end
end
