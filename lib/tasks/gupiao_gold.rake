# encoding:utf-8
require 'net/http'
require 'active_support/json'

desc "Get gold"
task :gupiao_gold => :environment do     
  Gupiao.trend
end