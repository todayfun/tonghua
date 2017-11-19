# encoding:utf-8
require 'net/http'
require 'active_support/json'

desc "Stock fin report quarterly"
task :fin_report => :environment do
  FinReport.import_finRpt
  FinReport.calc_profit_of_holderright
end