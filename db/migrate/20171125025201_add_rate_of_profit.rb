class AddRateOfProfit < ActiveRecord::Migration
  def up
    add_column :stocks,:rate_of_profit,:float
  end

  def down
    remove_column :stocks, :rate_of_profit
  end
end
