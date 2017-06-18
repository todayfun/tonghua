class AddNameToStock < ActiveRecord::Migration
  def change
    add_column :stocks,:name,:string
    add_column :stocks,:gpcode,:string

    add_index :stocks,[:gpcode]
  end
end
