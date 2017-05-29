# encoding:utf-8
require 'net/http'
require 'active_support/json'

desc "Import monthline from tenxun"
task :monthline_import => :environment do
  Monthline.import
end