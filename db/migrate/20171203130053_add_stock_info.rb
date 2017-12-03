class AddStockInfo < ActiveRecord::Migration
  def up
    add_column :stocks,:info,:text
  end

  def down
    remove_column :stocks,:info
  end
end
