# encoding:utf-8
require 'net/http'
require 'active_support/json'

desc "Import weekline from tenxun"
task :weekline_import => :environment do
  Weekline.import
end