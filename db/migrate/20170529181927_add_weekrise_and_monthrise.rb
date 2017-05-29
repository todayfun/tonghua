class AddWeekriseAndMonthrise < ActiveRecord::Migration
  def up
    add_column :stocks, :weekrise,:integer
    add_column :stocks,:monthrise,:integer

    add_index :stocks, :weekrise
    add_index :stocks, :monthrise
  end

  def down
    remove_column :stocks, :weekrise
    remove_column :stocks,:monthrise
    remove_index :stocks,:weekrise
    remove_index :stocks,:monthrise
  end
end
