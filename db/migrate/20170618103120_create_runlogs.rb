class CreateRunlogs < ActiveRecord::Migration
  def change
    create_table :runlogs do |t|
      t.string :code
      t.string :name
      t.string :status
      t.datetime :run_at

    end

    add_index :runlogs, [:code,:name]
    add_index :runlogs, :status
    add_index :runlogs, :run_at
  end
end
