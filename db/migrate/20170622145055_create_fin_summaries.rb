class CreateFinSummaries < ActiveRecord::Migration
  def change
    create_table :fin_summaries do |t|
      t.string :code
      t.date :repdate
      t.string :type
      t.text :matrix
      t.text :matrix_meta

      t.timestamps
    end

    add_index :fin_summaries, [:code,:repdate,:type],:unique => true
  end
end
