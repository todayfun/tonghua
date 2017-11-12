class AddProfitOfHolderRight < ActiveRecord::Migration
  def up
    add_column :fin_reports, :profit_of_holderright,:float
    add_index :fin_reports,:profit_of_holderright
  end

  def down
    remove_column :fin_reports,:profit_of_holderright
    remove_column :fin_reports,:profit_of_holderright
  end
end
