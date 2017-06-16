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
end
