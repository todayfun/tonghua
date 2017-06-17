module ApplicationHelper
  def fin_report_label(type)
    case type
      when FinReport::TYPE_Q1
        "Q1"
      when FinReport::TYPE_Q2
        "Q2"
      when FinReport::TYPE_Q3
        "Q3"
      when FinReport::TYPE_ANNUAL
        "FY"
      when FinReport::TYPE_SUM_Q2
        "SUM_Q2"
      when FinReport::TYPE_SUM_Q3
        "SUM_Q3"
      else
        "invalid"
    end
  end

  def cash_base_share(stock_type, gb, cash)
    (gb>1 ? (cash * (stock_type=="us" ? FinReport::US_UNIT : FinReport::HK_UNIT) / gb).round(2) : 0)
  end

  def stkholder_rights_of_debt(fd_non_liquid_debts,fd_stkholder_rights)
    total = fd_non_liquid_debts + fd_stkholder_rights
    if total < 0.001
      0
    else
      (fd_stkholder_rights / total).round(4)
    end
  end
end
