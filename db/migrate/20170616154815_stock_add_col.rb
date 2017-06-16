class StockAddCol < ActiveRecord::Migration
  def up
    add_column :stocks, :gb,:integer
    add_column :stocks, :sz,:integer
    add_column :stocks, :high52w,:float
    add_column :stocks, :low52w,:float
    add_column :stocks, :price,:float
    add_column :stocks,:pe,:float
  end

  def down
    remove_column :stocks, :gb,:sz,:high52w,:low52w,:price,:pe
  end
end
