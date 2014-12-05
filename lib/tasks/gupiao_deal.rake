# encoding:utf-8
require 'net/http'
require 'active_support/json'

desc "Get gupiao deal data"
task :gupiao_deal => :environment do     
  GupiaoDeal.query_gupiao_deal
end