class CreateGupiaoDeals < ActiveRecord::Migration
  def change
    create_table :gupiao_deals do |t|
      t.string :name
      t.string :code
      t.float :pc
      t.float :op
      t.float :vo
      t.float :tu
      t.float :hi
      t.float :lo
      t.float :la
      t.datetime :time
      t.float :sy
      t.float :lt
      t.float :sz
      t.float :hs
      t.string :sig
    end
    
    add_index :gupiao_deals, :code
    add_index :gupiao_deals, :sig
  end
end

=begin
na:"中国铁建",       //股票中文名称
pc:"7.22",           //昨收盘
op:"7.22",           //今开盘
vo:"174035",         //成交量
tu:"12804",          //成交额
hi:"7.42",           //最高价
lo:"7.22",           //最低价
la:"7.39",           //现价
type:"2",            //类型，1：指数，2：股票？
time:"2011-01-26 11:30:15", //时间
sy:"18.45",          //市盈率= 现价/最近四个季度摊薄每股收益之和
lt:"24.50",          //流通股数（单位：亿股）
sz:"911.74",         //总市值（单位：亿）
hs:"0.71",           //换手率
=end