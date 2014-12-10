# encoding:utf-8
require 'net/http'
require 'active_support/json'

desc "Get gupiao deal from yahoo"
task :yahoo_deal => :environment do     
  YahooDeal.query
end