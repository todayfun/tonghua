class GupiaoDeal < ActiveRecord::Base
  attr_accessible :code, :hi, :hs, :la, :lo, :lt, :name, :op, :pc, :sy, :sz, :time, :tu, :vo, :sig 
  
  def self.query_gupiao_deal
    codes = Gupiao.select("code").map(&:code)
    utf8=Encoding.find("UTF-8")
    gbk=Encoding.find("GBK")
        
    codes.in_groups_of(50,false) do |batch|
      url="http://bdcjhq.hexun.com/quote?s2=#{batch.join(',')}"
      rsp = Net::HTTP.get(URI.parse(url))
      md =  /bdcallback\((.*)\)\}/.match(rsp)
      json_str = md[1].gsub(/([a-z]+[0-9]*):/, '"\1":')
      
      raw_deals = ActiveSupport::JSON.decode json_str.encode(utf8,gbk)      
      GupiaoDeal.batch_save_deal batch, raw_deals    
    end
  end
  
  def self.batch_save_deal(codes,raw_deals)
    deals = {}
    gupiao_exceptions = {}
    gupiao_not_exists = []
    gupiao_stop = []
    gupiao_exists = []
    
    deal_on=Date.today
    codes.each do |code|
      r = raw_deals[code]
      
      if r.nil?        
        gupiao_exceptions[code]={code:code,exception:"not found",deal_on:deal_on, sig:"#{code},#{deal_on.to_s}"}
        gupiao_not_exists << code
        next
      end
      
      begin
        deal_on = Date.parse r['time']
      rescue        
        gupiao_exceptions[code]={code:code,exception:"stop,#{r['time']}",deal_on:deal_on, sig:"#{code},#{deal_on.to_s}"}
        gupiao_stop << code
        next
      end
      
      if r && r['na'] && deal_on       
        sig="#{code},#{deal_on.to_s}"
        gupiao_exists << code
        deals[sig] = {name:r['na'], code:code,pc:r['pc'],op:r['op'],
          vo:r['vo'],tu:r['tu'],hi:r['hi'],lo:r['lo'],la:r['la'],
          time:r['time'],sy:r['sy'],lt:r['lt'],sz:r['sz'],hs:r['hs'],sig:sig}
      end
    end
    
    # batch upate
    exist_sigs = []
    GupiaoDeal.connection.transaction do
      GupiaoDeal.where(:sig => deals.keys).each do |d|
        d.update_attributes deals[d.sig]
        exist_sigs << d.sig
      end
    end
    
    # update status
    Gupiao.where(:code=>gupiao_exists).update_all(:status=>"ACTIVE")
    Gupiao.where(:code=>gupiao_stop).update_all(:status=>"STOP")
    Gupiao.where(:code=>gupiao_not_exists).update_all(:status=>"NONE")
        
    # batch create
    new_deals = (deals.keys - exist_sigs).map {|sig| deals[sig]}
    GupiaoDeal.create new_deals
    
    exist_sigs = GupiaoException.select("sig").where(:deal_on=>deal_on).map(&:sig)
    new_exceptions = (gupiao_exceptions.keys - exist_sigs).map do |sig|
      gupiao_exceptions[sig]
    end
    
    GupiaoException.create new_exceptions
  end
end

