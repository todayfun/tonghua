# encoding:utf-8
require 'net/http'
require 'active_support/json'

desc "Stock rise trend"
task :stock_trend => :environment do
  Monthline.import
  Weekline.import
  Stock.rise_trend
end