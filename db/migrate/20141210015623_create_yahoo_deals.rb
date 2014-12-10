class CreateYahooDeals < ActiveRecord::Migration
  def change
    create_table :yahoo_deals do |t|
      t.string :code
      t.float :open
      t.float :close
      t.float :high
      t.float :low
      t.integer :volume
      t.float :adj # 复权收盘价
      t.date :on      
      t.string :sig
    end
    
    add_index :yahoo_deals, :code
    add_index :yahoo_deals, :on
    add_index :yahoo_deals, :sig
  end
end
