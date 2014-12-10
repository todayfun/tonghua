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

ActiveRecord::Schema.define(:version => 20141210055837) do

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

  create_table "yahoo_deals", :force => true do |t|
    t.string "code"
    t.text   "deals"
    t.text   "trend"
    t.text   "judge"
  end

  add_index "yahoo_deals", ["code"], :name => "index_yahoo_deals_on_code"
  add_index "yahoo_deals", ["judge"], :name => "index_yahoo_deals_on_judge"

end
