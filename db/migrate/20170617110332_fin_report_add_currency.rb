class FinReportAddCurrency < ActiveRecord::Migration
  def up
    add_column :fin_reports, :currency, :string
  end

  def down
    remove_column :fin_reports, :currency
  end
end
