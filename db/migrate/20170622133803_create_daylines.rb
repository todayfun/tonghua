class CreateDaylines < ActiveRecord::Migration
  def change
    create_table :daylines do |t|
      t.string :code
      t.date :day
      t.float :open
      t.float :close
      t.float :high
      t.float :low
      t.integer :vol

      t.timestamps
    end

    add_index :daylines, [:code,:day],:unique => true
    add_index :daylines, :open
    add_index :daylines, :close
  end
end
