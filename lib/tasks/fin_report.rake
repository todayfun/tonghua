# encoding:utf-8
require 'net/http'
require 'active_support/json'

desc "Stock fin report quarterly"
task :fin_report => :environment do
  FinReport.import_finRpt
  #Stock.import_summary
end