# encoding:utf-8
require 'net/http'
require 'active_support/json'

desc "Refresh or import a stock: rake refresh_stock code=hk00175"
task :refresh_stock => :environment do
  Stock.refresh ENV["code"].split(',')
end