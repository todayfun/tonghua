# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20171203130053) do

  create_table "daylines", :force => true do |t|
    t.string   "code"
    t.date     "day"
    t.float    "open"
    t.float    "close"
    t.float    "high"
    t.float    "low"
    t.integer  "vol"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "daylines", ["close"], :name => "index_daylines_on_close"
  add_index "daylines", ["code", "day"], :name => "index_daylines_on_code_and_day", :unique => true
  add_index "daylines", ["open"], :name => "index_daylines_on_open"

  create_table "fin_reports", :force => true do |t|
    t.string   "fd_code"
    t.integer  "fd_year"
    t.datetime "fd_repdate"
    t.string   "fd_type"
    t.float    "fd_turnover"
    t.float    "fd_profit_after_tax"
    t.float    "fd_profit_base_share"
    t.float    "fd_profit_after_share"
    t.datetime "created_at",             :null => false
    t.datetime "updated_at",             :null => false
    t.float    "fd_dividend_base_share"
    t.float    "fd_non_liquid_debts"
    t.float    "fd_stkholder_rights"
    t.float    "fd_liquid_debts"
    t.float    "fd_liquid_assets"
    t.float    "fd_cash_and_deposit"
    t.string   "currency"
    t.float    "operating_cash"
    t.float    "invest_cash"
    t.float    "loan_cash"
    t.float    "profit_of_holderright"
    t.float    "profit"
  end

  add_index "fin_reports", ["fd_code", "fd_repdate"], :name => "index_fin_reports_on_fd_code_and_fd_repdate", :unique => true
  add_index "fin_reports", ["fd_code"], :name => "index_fin_reports_on_fd_code"
  add_index "fin_reports", ["profit_of_holderright"], :name => "index_fin_reports_on_profit_of_holderright"

  create_table "fin_summaries", :force => true do |t|
    t.string   "code"
    t.date     "repdate"
    t.string   "type"
    t.text     "matrix"
    t.text     "matrix_meta"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "fin_summaries", ["code", "repdate", "type"], :name => "index_fin_summaries_on_code_and_repdate_and_type", :unique => true

  create_table "gupiao_deals", :force => true do |t|
    t.string   "name"
    t.string   "code"
    t.float    "pc"
    t.float    "op"
    t.float    "vo"
    t.float    "tu"
    t.float    "hi"
    t.float    "lo"
    t.float    "la"
    t.datetime "time"
    t.float    "sy"
    t.float    "lt"
    t.float    "sz"
    t.float    "hs"
    t.string   "sig"
  end

  add_index "gupiao_deals", ["code"], :name => "index_gupiao_deals_on_code"
  add_index "gupiao_deals", ["sig"], :name => "index_gupiao_deals_on_sig"

  create_table "gupiao_exceptions", :force => true do |t|
    t.string "code"
    t.string "exception"
    t.date   "deal_on"
    t.string "sig"
  end

  add_index "gupiao_exceptions", ["code"], :name => "index_gupiao_exceptions_on_code"
  add_index "gupiao_exceptions", ["sig"], :name => "index_gupiao_exceptions_on_sig"

  create_table "gupiaos", :force => true do |t|
    t.string   "name"
    t.string   "code"
    t.string   "trend"
    t.string   "stamp"
    t.string   "status"
    t.string   "judge"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "monthlines", :force => true do |t|
    t.string   "code"
    t.date     "day"
    t.float    "open"
    t.float    "close"
    t.float    "high"
    t.float    "low"
    t.integer  "vol"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "monthlines", ["close"], :name => "index_monthlines_on_close"
  add_index "monthlines", ["code", "day"], :name => "index_monthlines_on_code_and_day", :unique => true
  add_index "monthlines", ["open"], :name => "index_monthlines_on_open"

  create_table "runlogs", :force => true do |t|
    t.string   "code"
    t.string   "name"
    t.string   "status"
    t.datetime "run_at"
  end

  add_index "runlogs", ["code", "name"], :name => "index_runlogs_on_code_and_name"
  add_index "runlogs", ["run_at"], :name => "index_runlogs_on_run_at"
  add_index "runlogs", ["status"], :name => "index_runlogs_on_status"

  create_table "stocks", :force => true do |t|
    t.string   "code"
    t.string   "stamp"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
    t.integer  "weekrise"
    t.integer  "monthrise"
    t.integer  "gb"
    t.integer  "sz"
    t.float    "high52w"
    t.float    "low52w"
    t.float    "price"
    t.float    "pe"
    t.string   "name"
    t.string   "gpcode"
    t.text     "good"
    t.text     "bad"
    t.float    "roe"
    t.float    "rate_of_profit"
    t.text     "info"
  end

  add_index "stocks", ["code"], :name => "sqlite_autoindex_stocks_1", :unique => true
  add_index "stocks", ["gpcode"], :name => "index_stocks_on_gpcode"
  add_index "stocks", ["monthrise"], :name => "index_stocks_on_monthrise"
  add_index "stocks", ["weekrise"], :name => "index_stocks_on_weekrise"

  create_table "weeklines", :force => true do |t|
    t.string   "code"
    t.date     "day"
    t.float    "open"
    t.float    "close"
    t.float    "high"
    t.float    "low"
    t.integer  "vol"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "weeklines", ["close"], :name => "index_weeklines_on_close"
  add_index "weeklines", ["code", "day"], :name => "index_weeklines_on_code_and_day", :unique => true
  add_index "weeklines", ["open"], :name => "index_weeklines_on_open"

  create_table "yahoo_deals", :force => true do |t|
    t.string "code"
    t.text   "deals"
    t.text   "trend"
    t.text   "judge"
  end

  add_index "yahoo_deals", ["code"], :name => "index_yahoo_deals_on_code"
  add_index "yahoo_deals", ["judge"], :name => "index_yahoo_deals_on_judge"

end
