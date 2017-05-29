class CreateWeeklines < ActiveRecord::Migration
  def change
    create_table :weeklines do |t|
      t.string :code
      t.date :day
      t.float :open
      t.float :close
      t.float :high
      t.float :low
      t.integer :vol

      t.timestamps
    end

    add_index :weeklines, [:code,:day],:unique => true
    add_index :weeklines, :open
    add_index :weeklines, :close
  end
end
