class AddGoodAndBadToStock < ActiveRecord::Migration
  def change
    add_column :stocks,:good,:text
    add_column :stocks,:bad,:text
  end
end
