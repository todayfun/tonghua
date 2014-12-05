class Gupiao < ActiveRecord::Base
  attr_accessible :code, :judge, :name, :stamp, :status, :trend
  
  def self.trend(day=3)
    codes = Gupiao.where(:status=>"ACTIVE").select("code").map(&:code)
    
    Gupiao.where(:status=>"ACTIVE").each do |gupiao|
      deals = GupiaoDeal.where(:code=>gupiao.code).select("code,op,la,vo,time").order("time desc").limit(day+1)
      trend = {deal_on:[], op:[], la:[], vo:[]}
      deals.map do |r|
        trend[:deal_on] << r['time'].to_date
        trend[:op] << r.op
        trend[:la] << r.la
        trend[:vo] << r.vo        
      end
      
      judge=[]
      judge << "GOLD" if self.is_gold? trend
      judge << "UP_LIMIT" if self.is_up_limit? trend  
      
      gupiao.update_attributes(:trend=>trend.to_json, :judge=>judge.to_json)
    end
  end
  
  def self.is_gold?(trend)
    if trend[:op].size < 2
      return false
    end
    
    flg = true
    (0...trend[:op].size).to_a.each do |idx|
      flg = flg && (trend[:la][idx] > trend[:la][idx+1]) && (trend[:vo][idx] < trend[:vo][idx+1])
      break unless flg
    end
  end
  
  def self.is_up_limit?(trend)
    if trend[:op].size < 2
      return false
    end
    
    flg=(trend[:la][0]>trend[:op][0]*1.08) && (trend[:op][0]>trend[:pc][0]) # 开盘比昨天高，今天涨幅8%以上
    return flg
  end
  
end
