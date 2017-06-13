class FinReportsController < ApplicationController
  # GET /fin_reports
  # GET /fin_reports.json
  def index
    @fin_reports = FinReport.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @fin_reports }
    end
  end

  # GET /fin_reports/1
  # GET /fin_reports/1.json
  def show
    @fin_report = FinReport.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @fin_report }
    end
  end

  # GET /fin_reports/new
  # GET /fin_reports/new.json
  def new
    @fin_report = FinReport.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @fin_report }
    end
  end

  # GET /fin_reports/1/edit
  def edit
    @fin_report = FinReport.find(params[:id])
  end

  # POST /fin_reports
  # POST /fin_reports.json
  def create
    @fin_report = FinReport.new(params[:fin_report])

    respond_to do |format|
      if @fin_report.save
        format.html { redirect_to @fin_report, notice: 'Fin report was successfully created.' }
        format.json { render json: @fin_report, status: :created, location: @fin_report }
      else
        format.html { render action: "new" }
        format.json { render json: @fin_report.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /fin_reports/1
  # PUT /fin_reports/1.json
  def update
    @fin_report = FinReport.find(params[:id])

    respond_to do |format|
      if @fin_report.update_attributes(params[:fin_report])
        format.html { redirect_to @fin_report, notice: 'Fin report was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @fin_report.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /fin_reports/1
  # DELETE /fin_reports/1.json
  def destroy
    @fin_report = FinReport.find(params[:id])
    @fin_report.destroy

    respond_to do |format|
      format.html { redirect_to fin_reports_url }
      format.json { head :no_content }
    end
  end
end
