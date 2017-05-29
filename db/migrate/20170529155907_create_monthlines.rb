class CreateMonthlines < ActiveRecord::Migration
  def change
    create_table :monthlines do |t|
      t.string :code
      t.date :day
      t.float :open
      t.float :close
      t.float :high
      t.float :low
      t.integer :vol

      t.timestamps
    end

    add_index :monthlines, [:code,:day],:unique => true
    add_index :monthlines, :open
    add_index :monthlines, :close
  end
end
