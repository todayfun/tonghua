class Stock < ActiveRecord::Base
  attr_accessible :code, :stamp, :weekrise, :monthrise, :gb,:sz,:low52w, :high52w, :price,:pe, :gpcode,:name,
                  :good,:bad

  serialize :good, JSON
  serialize :bad,JSON

  # http://web.ifzq.gtimg.cn/portable/mobile/qt/data?code=hk00700
  # {"code":0,"msg":"ok","data":{"ssl":0,"sjl":0,"gb":0,"px":0,"avgm":0,"newpri":"272.60","yespri":"273.00","higpri":"276.40","lowpri":"272.60","volume":"20927343.0","dt":"2017\/06\/16 16:09:09","zd":"-0.40","zdf":"-0.15","sz":"25837.12","pe":"55.97","psy":"0.22","52wh":"283.40","52wl":"167.00"}}
  def self.import_summary
    stocks = Stock.all
    stocks.each do |stock|
      import_summary_one stock
    end
  end

  def self.import_summary_one(stock)
    url = "http://web.ifzq.gtimg.cn/portable/mobile/qt/data?code=#{stock.code}"
    rsp = Net::HTTP.get(URI.parse(url))
    json = ActiveSupport::JSON.decode(rsp)
    data = json["data"]

    return if data.blank?
    pri = data["newpri"].to_f
    return if pri<0.001

    sz = data["sz"].to_f*100000000
    gb = (sz / data["newpri"].to_f).to_i
    stock.update_attributes gb:gb,sz:sz,low52w:data["52wl"],high52w:data["52wh"],price:data["newpri"],pe:data["pe"]
  end

  def self.rise_trend(weekcnt=4,monthcnt=24)
    stocks = Stock.all

    stocks.each do |s|
      rise_trend_one s,weekcnt,monthcnt
    end
  end

  def self.rise_trend_one(stock,weekcnt,monthcnt)
    monthrise = Monthline.rise_trend stock.code, monthcnt
    weekrise = Weekline.rise_trend stock.code, weekcnt
    stock.update_attributes monthrise:monthrise, weekrise:weekrise
  end

  def self.import
    us_stocks = %w{
    usA.N usAA.N usAAPL.OQ usAAXJ.OQ usABAC.OQ usABT.N usABX.N usACH.N usACXM.OQ usADBE.OQ usADI.OQ usADS.N usADSK.OQ usAEP.N usAES.N usAGQ.AM usAIG.N usAKAM.OQ
    usAL.N usALL.N usALN.AM usAMAT.OQ usAMBA.OQ usAMCN.OQ usAMD.OQ usAMGN.OQ usAMRC.N usAMZN.OQ usAPH.N usARRS.OQ usASHR.AM usASHS.AM usASX.N usATHM.N usATI.N
    usATSG.OQ usATV.N usATVI.OQ usAUO.N usAVG.N usAVGO.OQ usAVP.N usAXP.N usB.N usBA.N usBABA.N usBAC.N usBAX.N usBBRY.OQ usBBY.N usBHI.N usBHP.N usBIDU.OQ usBIIB.OQ
    usBITA.N usBK.N usBLDP.OQ usBLK.N usBMY.N usBOX.N usBP.N usBRCD.OQ usBUD.N usBX.N usBZUN.OQ usC.N usCA.OQ usCAAS.OQ usCAF.N usCAJ.N usCALI.OQ usCAT.N usCBAK.OQ
    usCBPO.OQ usCBS.N usCCCR.OQ usCCIH.OQ usCCM.N usCCRC.OQ usCCU.N usCDNS.OQ usCEA.N usCELG.OQ usCEO.N usCETC.OQ usCHA.N usCHAD.AM usCHAU.AM usCHL.N usCHNR.OQ usCHT.N
    usCHU.N usCI.N usCL.N usCMCM.N usCMCSA.OQ usCMG.N usCNET.OQ usCNIT.OQ usCNTF.OQ usCNXT.AM usCNYA.AM usCO.N usCOF.N usCOH.N usCOP.N usCOST.OQ usCPB.N usCPHI.AM
    usCREE.OQ usCRM.N usCSC.N usCSCO.OQ usCSIQ.OQ usCTRP.OQ usCTSH.OQ usCTXS.OQ usCVLT.OQ usCVS.N usCVX.N usCXDC.OQ usCY.OQ usCYB.AM usCYBR.OQ usCYD.N usCYOU.OQ usD.N
    usDAL.N usDATA.N usDB.N usDBA.AM usDBC.AM usDD.N usDDD.N usDDM.AM usDGAZ.AM usDGP.AM usDGZ.AM usDIA.AM usDIG.AM usDIS.N usDL.N usDLB.N usDNR.N usDOG.AM usDOW.N
    usDQ.N usDRN.AM usDRV.AM usDTO.AM usDTV.N usDUG.AM usDUK.N usDUST.AM usDVA.N usDWT.AM usDXCM.OQ usDXD.AM usDXJ.AM usDZZ.AM usE.N usEA.OQ usEBAY.OQ usEDC.AM usEDIT.OQ
    usEDU.N usEEM.AM usEFA.AM usEHIC.N usEL.N usENV.N usEQIX.OQ usERIC.OQ usERX.AM usERY.AM usETR.N usEUO.AM usEWA.AM usEWC.AM usEWD.AM usEWG.AM usEWH.AM usEWI.AM usEWJ.AM
    usEWK.AM usEWM.AM usEWN.AM usEWO.AM usEWP.AM usEWQ.AM usEWT.AM usEWU.AM usEWY.AM usEWZ.AM usEXC.N usEXPE.OQ usEZU.AM usF.N usFAS.AM usFAZ.AM usFB.OQ usFCEL.OQ usFDX.N
    usFENG.N usFEYE.OQ usFFIV.OQ usFIT.N usFORK.OQ usFRI.AM usFSLR.OQ usFTNT.OQ usFXA.AM usFXC.AM usFXE.AM usFXF.AM usFXI.AM usFXP.AM usFXY.AM usGD.N usGDOT.N usGDX.AM usGDXJ.AM
    usGE.N usGG.N usGIGM.OQ usGILD.OQ usGLD.AM usGLL.AM usGLUU.OQ usGLW.N usGM.N usGMAN.OQ usGME.N usGOGO.OQ usGOOG.OQ usGOOGL.OQ usGPRO.OQ usGRO.N usGRPN.OQ usGRUB.N usGS.N usGSH.N
    usGSK.N usGSOL.OQ usH.N usHAL.N usHCM.OQ usHD.N usHIG.N usHIMX.OQ usHLF.N usHLG.OQ usHMC.N usHNP.N usHOLI.OQ usHON.N usHPQ.N usHQCL.OQ usHSBC.N usHTHT.OQ usIAU.AM usIBB.OQ usIBKR.OQ
    usIBM.N usICF.AM usILMN.OQ usINTC.OQ usINTU.OQ usINVN.N usIP.N usIRBT.OQ usISRG.OQ usITB.AM usIVV.AM usIWM.AM usIWO.AM usIYF.AM usIYM.AM usIYR.AM usIYT.AM usIYZ.AM usJASO.OQ usJBL.N
    usJCP.N usJD.OQ usJKS.N usJMEI.N usJNJ.N usJNPR.N usJOBS.OQ usJPM.N usJRJC.OQ usJUNO.OQ usK.N usKANG.OQ usKBE.AM usKBSF.OQ usKIE.AM usKITE.OQ usKLAC.OQ usKNDI.OQ usKO.N usKORS.N
    usKWEB.OQ usKWT.AM usKYO.N usKZ.OQ usLC.N usLEJU.N usLFC.N usLITB.N usLMT.N usLN.N usLRCX.OQ usLSCC.OQ usLTBR.OQ usLUV.N usLVS.N usM.N usMA.N usMAT.OQ usMBLY.N usMCD.N usMCHP.OQ
    usMCO.N usMDSO.OQ usMDT.N usMET.N usMFG.N usMGM.N usMJN.N usMMI.N usMMM.N usMMYT.OQ usMNKD.OQ usMO.N usMOMO.OQ usMON.N usMOO.AM usMPEL.OQ usMPG.N usMRK.N usMRVL.OQ usMS.N usMSFT.OQ
    usMSI.N usMTU.N usMU.OQ usMXIM.OQ usMXWL.OQ usN.N usNCTY.OQ usNDAQ.OQ usNFLX.OQ usNHTC.OQ usNKE.N usNLR.AM usNMBL.N usNMR.N usNOAH.N usNOK.N usNORD.N usNQ.N usNSC.N usNTAP.OQ usNTES.OQ
    usNTP.N usNTT.N usNUAN.OQ usNUGT.AM usNUS.N usNVDA.OQ usNVS.N usNWS.OQ usNXPI.OQ usNYT.N usOIH.AM usOIIM.OQ usOIL.AM usORCL.N usOSN.OQ usP.N usPANW.N usPBR.N usPCLN.OQ usPEP.N usPFE.N
    usPG.N usPGF.AM usPGJ.OQ usPHG.N usPLUG.OQ usPME.OQ usPSQ.AM usPTR.N usPYPL.OQ usQCOM.OQ usQID.AM usQIWI.OQ usQLD.AM usQQQ.OQ usRACE.N usRENN.N usRF.N usRHT.N usRIO.N usRJA.AM usRJI.AM
    usROK.N usRP.OQ usRSX.AM usRTH.AM usRTN.N usRUSL.AM usRUSS.AM usRWLK.OQ usRWM.AM usS.N usSAP.N usSATS.OQ usSBUX.OQ usSCO.AM usSPIL.OQ usSPLK.OQ usSPWR.OQ usSPXU.AM usSPY.AM usSQ.N usSQQQ.OQ
    usSRS.AM usSSO.AM usSSYS.OQ usSTV.N usSTX.OQ usSVA.OQ usSVXY.AM usSWFT.N usSWKS.OQ usSYMC.OQ usSYNT.OQ usT.N usTAL.N usTAN.AM usTCRD.OQ usTDC.N usTEDU.OQ usTER.N usTGT.N usTIF.N usTM.N usTNA.AM
    usTOUR.OQ usTQQQ.OQ usTRI.N usTRIP.OQ usTRMB.OQ usTRUE.OQ usTRV.N usTSLA.OQ usTSM.N usTUR.AM usTVIX.OQ usTWM.AM usTWTR.N usTWX.N usTXN.OQ usTYL.N usTZA.AM usUA.N usUBS.N usUCO.AM usUDN.AM usUDOW.AM
    usUGAZ.AM usUGL.AM usUMC.N usUNG.AM usUNH.N usUPRO.AM usUPS.N usURE.AM usUSB.N usUSNA.N usUSO.AM usUTSI.OQ usUTX.N usUUP.AM usUVXY.AM usUWM.AM usUWT.AM usUYG.AM usUYM.AM usV.N usVALE.N usVEA.AM
    usVGK.AM usVIPS.N usVISN.OQ usVIXY.AM usVMW.N usVNET.OQ usVNQ.AM usVOD.OQ usVRSN.OQ usVRX.N usVWO.AM usVXX.AM usVXZ.AM usVZ.N usW.N usWB.OQ usWBAI.N usWDAY.N usWDC.OQ usWFC.N usWMB.N usWMT.N usWPZ.N
    usWUBA.N usWY.N usWYNN.OQ usX.N usXHB.AM usXIN.N usXIV.OQ usXLB.AM usXLE.AM usXLF.AM usXLI.AM usXLK.AM usXLNX.OQ usXLP.AM usXLU.AM usXLV.AM usXLY.AM usXME.AM usXNET.OQ usXOM.N usXONE.OQ usXPP.AM usXRT.AM
    usXRX.N usY.N usYANG.AM usYCS.AM usYECO.OQ usYELP.N usYGE.N usYHOO.OQ usYIN.OQ usYINN.AM usYNDX.OQ usYOD.OQ usYRD.N usYUM.N usYXI.AM usYY.OQ usYZC.N usZ.OQ usZNGA.OQ usZNH.N usZPIN.N usZSL.AM usZX.N
    }

    hk_stocks = %w{
    hk01513 hk02318 hk01211 hk06826 hk03898 hk01336 hk00168 hk01099 hk02120 hk03606 hk02601 hk02196 hk00914 hk02628 hk03968 hk00696 hk03396 hk02607 hk00874 hk02202
    hk03636 hk01088 hk01558 hk06030 hk01776 hk00763 hk02611 hk06886 hk06869 hk00317 hk06837 hk02039 hk02328 hk01858 hk02338 hk02238 hk02777 hk01666 hk00895 hk06099
    hk00358 hk02208 hk03689 hk03908 hk00694 hk06178 hk00177 hk00921 hk01186 hk01800 hk01588 hk06116 hk00576 hk01812 hk00416 hk00489 hk01528 hk02333 hk02289 hk01988
    hk00753 hk01958 hk06066 hk00548 hk01766 hk03958 hk02386 hk06881 hk01527 hk02883 hk01799 hk01072 hk00811 hk01057 hk01818 hk00390 hk00939 hk02066 hk03948 hk00357
    hk00386 hk01963 hk00719 hk00902 hk01171 hk01066 hk03328 hk01055 hk00916 hk01292 hk00995 hk01349 hk03969 hk01829 hk02355 hk01385 hk01578 hk03618 hk00857 hk00347
    hk01398 hk03399 hk06189 hk01065 hk00998 hk06122 hk02357 hk01658 hk06196 hk00553 hk00670 hk01599 hk00338 hk00552 hk03323 hk06198 hk01138 hk01133 hk02218 hk00525
    hk02016 hk01330 hk01108 hk00564 hk01375 hk01456 hk00038 hk00980 hk03988 hk00728 hk02009 hk00161 hk03698 hk01288 hk02868 hk00598 hk01071 hk02600 hk01596 hk06818
    hk01635 hk01919 hk06839 hk01157 hk01786 hk01898 hk02727 hk01339 hk00107 hk00588 hk02799 hk03768 hk01359 hk01289 hk00991 hk00323 hk01618 hk06138 hk01122 hk00958
    hk02899 hk03993 hk01893 hk03369 hk06188 hk01816 hk00814 hk00187 hk00579 hk02068 hk00042 hk02006 hk03983 hk01606 hk03330 hk00816 hk02281 hk01508 hk01577 hk02866
    hk01461 hk06865 hk00956 hk02345 hk03996 hk03378 hk01543 hk03332 hk02880 hk01033 hk01459 hk00568 hk02308 hk01053 hk00549 hk02722 hk00954 hk06866 hk03833 hk03355
    hk01798 hk00438 hk01103 hk01265 hk03903 hk01075 hk01296 hk00747 hk00941 hk02588 hk00392 hk02388 hk01193 hk00363 hk00688 hk00144 hk01109 hk00966 hk00291 hk00165 hk01111 hk00836 hk02319 hk01114 hk03311 hk00152 hk02099 hk00267
    hk00133 hk01316 hk00762 hk00270 hk01347 hk00257 hk01848 hk03320 hk01199 hk00883 hk01135 hk00981 hk03360 hk00135 hk02666 hk01249 hk00371 hk00222 hk02299 hk01052
    hk03899 hk03808 hk00735 hk00992 hk01908 hk00882 hk00710 hk00081 hk01045 hk00906 hk00934 hk00570 hk06139 hk00687 hk01313 hk01070 hk00604 hk00606 hk01828 hk00119
    hk02302 hk00517 hk00218 hk00506 hk02380 hk00993 hk00337 hk03366 hk01206 hk01208 hk01788 hk00817 hk01329 hk01883 hk00308 hk00560 hk00124 hk00563 hk00903 hk00368
    hk00365 hk02886 hk00978 hk00596 hk01610 hk02339 hk01522 hk00154 hk01230 hk02669 hk00085 hk00123 hk03382 hk00639 hk00908 hk01258 hk00207 hk00171 hk00611 hk01058
    hk01148 hk01811 hk00830 hk01639 hk01203 hk00334 hk00031 hk00420 hk00297 hk01205 hk00230 hk00111 hk02362 hk00798 hk00132 hk01185 hk00305 hk00281 hk01164 hk00418
    hk01312 hk00232 hk01091 hk00445 hk00181 hk00217 hk00925 hk01175 hk00521 hk01062 hk00618 hk00103 hk00812 hk00982 hk00730 hk00697 hk03989 hk01250 hk00346 hk00809
    hk00260 hk00755 hk00661
    }

    us_stocks.each do |code|
      Stock.create code:code,stamp:"us"
    end

    hk_stocks.each do |code|
      Stock.create code:code, stamp:"hk"
    end
  end

  def self.refresh codes
    puts codes.inspect
    codes.each do |code|
      refresh_one code
    end
  end

  def self.refresh_one code
    stock = Stock.find_by_code code

    if stock.nil?
      stock = Stock.create code:code, stamp:(code.match(/^hk/i) ? "hk" : "us")
    end

    import_summary_one stock
    Weekline.import_weekline stock.code,stock.stamp
    Monthline.import_monthline stock.code,stock.stamp
    rise_trend_one stock,4,24
    FinReport.import_finRpt_one stock

    true
  end

  def self.clear_has_none_fin_report
    stocks = Stock.select("id,code").all
    codes = FinReport.select("distinct fd_code").all.map &:fd_code
    cnt = 0
    stocks.each do |s|
      if codes.include? s.code

      else
        puts s.code
        s.delete
        cnt += 1
      end
    end

    puts "clear_has_none_fin_report: #{cnt}"
    cnt
  end

=begin
从雪球爬股票代码
url = "https://xueqiu.com/S/list/search"
rsp = Net::HTTP.post_form URI(url), page:100,size:5,exchange:"US",order:"desc",orderby:"percent"
rsp.body:
{"industries":[{},{}],"stocks":{"count":{"count":4142},"success":"true",
"stocks":[{"symbol":"FOLD","code":"FOLD","name":"爱美医疗","current":"9.43","percent":"7.28","change":"0.64","high":"9.48","low":"8.59","high52w":"9.61","low52w":"4.41","marketcapital":"1.256238E9","amount":"4.350504197E7","type":"0","pettm":"","volume":"4713439","hasexist":"false"}
=end

  def self.import_stocks_from_xueqiu
    stocks = Stock.all
    stocks_hash = {}
    stocks.each do |stock|
      if stock.gpcode.nil?
        if stock.stamp == "us"
          stock.gpcode = stock.code.match(/[A-Z]/)[1]
        else
          stock.gpcode = stock.code.sub(/hk/,"")
        end

        stock.save
      end
      stocks_hash["#{stock.gpcode},#{stock.stamp}"]=stock
    end

    import_stocks_from_xueqiu_by_stamp stocks_hash,"us"
    import_stocks_from_xueqiu_by_stamp stocks_hash,"hk"

  end

  def self.import_stocks_from_xueqiu_by_stamp stocks_hash,stamp
    page = 1
    while true
      url = "https://xueqiu.com/S/list/search"
      rsp = Net::HTTP.post_form URI(url), page:page,size:100,exchange:stamp.upcase,order:"desc",orderby:"percent"
      xueqiu_stocks = ActiveSupport::JSON.decode(rsp.body)["stocks"]["stocks"]

      cnt = 0
      xueqiu_stocks.each do |s|
        if stocks_hash["#{s["code"]},#{stamp}"]
          next
        else
          stock = save_stock_from_xueqiu s, stamp
          stocks_hash["#{stock.gpcode},#{stamp}"]
        end
      end

      puts "imported #{cnt} stocks from xueqiu"

      break if xueqiu_stocks.blank?
      page += 1
    end
  end

  # :code, :stamp, :weekrise, :monthrise, :gb,:sz,:low52w, :high52w, :price,:pe, :gpcode,:name
  def self.save_stock_from_xueqiu xuqiu_stock,stamp
    if stamp=="us"
      full_code = translate_tengxun_code xuqiu_stock["code"]
    else
      full_code = "#{stamp}#{xuqiu_stock["code"]}"
    end

    stock = Stock.create code:full_code,stamp:stamp,
                         gb:xuqiu_stock["amount"],sz:xuqiu_stock["marketcapital"],
                         low52w:xuqiu_stock["low52w"],high52w:xuqiu_stock["high52w"],
                         price:xuqiu_stock["current"],pe:xuqiu_stock["pettm"],
                         gpcode:xuqiu_stock["code"],name:xuqiu_stock["name"]

    stock
  end

  # 换取美股在腾讯上的代码
  def self.translate_tengxun_code gpcode
    url = "http://gu.qq.com/#{gpcode}"
    rsp = Net::HTTP.get(URI.parse(url))
    full_code = rsp.split('/').last

    full_code
  end

  def mark_good_or_bad!(mark)
    good = self.good || {}
    bad = self.bad || {}

    if mark == "good"
      good["mark_at"] = Date.today.to_s
      bad.delete "mark_at"

      self.good = good
      self.bad = bad
      self.save
    elsif mark == "bad"
      bad["mark_at"] = Date.today.to_s
      good.delete "mark_at"

      self.bad = bad
      self.good = good
      self.save
    elsif mark = "clear"
      good.delete "mark_at"
      bad.delete "mark_at"

      self.bad = bad
      self.good = good
      self.save
    end
  end
end
