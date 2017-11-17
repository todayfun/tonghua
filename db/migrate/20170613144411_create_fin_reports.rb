class CreateFinReports < ActiveRecord::Migration
  def change
    create_table :fin_reports do |t|
      t.string :fd_code
      t.integer :fd_year
      t.datetime :fd_repdate
      t.string :fd_type
      t.float :fd_turnover
      t.float :fd_profit_after_tax
      t.float :fd_profit_base_share
      t.float :fd_profit_after_share

      t.timestamps
    end

    add_index :fin_reports, :fd_code
    add_index :fin_reports, [:fd_code, :fd_repdate],:unique => true
  end
end
