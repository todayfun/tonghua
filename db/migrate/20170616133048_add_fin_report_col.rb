class AddFinReportCol < ActiveRecord::Migration
  def up
    add_column :fin_reports, :fd_dividend_base_share,:float
    add_column :fin_reports, :fd_non_liquid_debts,:float
    add_column :fin_reports, :fd_stkholder_rights,:float
    add_column :fin_reports, :fd_liquid_debts,:float
    add_column :fin_reports, :fd_liquid_assets,:float
    add_column :fin_reports, :fd_cash_and_deposit,:float

  end

  def down
    remove_column :fin_reports,:fd_dividend_base_share
    remove_column :fin_reports,:fd_non_liquid_debts
    remove_column :fin_reports,:fd_stkholder_rights
    remove_column :fin_reports,:fd_liquid_debts
    remove_column :fin_reports,:fd_liquid_assets
    remove_column :fin_reports,:fd_cash_and_deposit
  end
end
