# encoding:utf-8
require 'net/http'
require 'active_support/json'

desc "Stock rise trend weekly"
task :stock_trend => :environment do
  Monthline.import
  Weekline.import
  Dayline.import if ENV["skip"]!="Dayline"
  Stock.import_summary
  Stock.rise_trend
  FinSummary.import
end