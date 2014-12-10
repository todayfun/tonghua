class CreateYahooDeals < ActiveRecord::Migration
  def change
    create_table :yahoo_deals do |t|
      t.string :code
      t.text :deals
      t.text :trend
      t.text :judge      
    end
    
    add_index :yahoo_deals, :code
    add_index :yahoo_deals, :judge
  end
end
