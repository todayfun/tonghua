class AddStockRoe < ActiveRecord::Migration
  def up
    add_column :stocks, :roe,:float
  end

  def down
    remove_column :stocks,:roe
  end
end
