class AddProfitToFinreport < ActiveRecord::Migration
  def change
    add_column :fin_reports, :profit, :float
  end
end
