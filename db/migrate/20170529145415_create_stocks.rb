class CreateStocks < ActiveRecord::Migration
  def change
    create_table :stocks do |t|
      t.string :code
      t.string :stamp
      t.date :date


      t.timestamps
    end

    add_index :stocks, :code,:unique => true
  end
end
