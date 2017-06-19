class AddCashToFinReport < ActiveRecord::Migration
  def change
    add_column :fin_reports,:operating_cash,:float
    add_column :fin_reports,:invest_cash,:float
    add_column :fin_reports,:loan_cash,:float
  end
end
