class Runlog < ActiveRecord::Base
  attr_accessible :code, :name, :run_at, :status

  NAME_FINRPT = "FINRPT"
  NAME_DAYLINE = "DAYLINE"
  NAME_WEEKLINE = "WEEKLINE"
  NAME_MONTHLINE = "MONTHLINE"
  NAME_STOCK_SUMMARY = "STOCK_SUMMARY"

  STATUS_OK = "OK"
  STATUS_ERROR = "ERROR"
  STATUS_DISABLE = "DISABLE"
  STATUS_IGNORE = "IGNORE"

  def self.update_log(code,name,status)
    status ||= STATUS_ERROR

    log = Runlog.where(code:code,name:name).first
    if log
      log.update_attributes status:status,run_at:Time.now
    else
      log = Runlog.create code:code,name:name,status:status,run_at:Time.now
    end
  end

  def self.ignored(name,ignored_statuses,before_run_at)
    if ignored_statuses.is_a? Array
      codes = Runlog.where(name:name).where("run_at > '#{before_run_at.strftime('%Y-%m-%d')}' or status in (#{ignored_statuses.to_s[1...-1]})").map &:code
    else
      codes = Runlog.where(name:name).where("run_at > '#{before_run_at.strftime('%Y-%m-%d')}' or status in (\"#{ignored_statuses}\")").map &:code
    end
    codes
  end
end
