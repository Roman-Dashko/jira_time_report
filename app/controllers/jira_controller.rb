class JiraController < ApplicationController

# will respond with head(:unauthorized) if verification fails
#   before_action only: [:index] do |controller|
#     controller.send(:verify_jwt, 'app-moc-report')
#   end

  def index
    # request_OAuth_access_token
    @form_params = Reports::TimeReport.create_form_params
  end

  def show(options = {})

    params['group_by'] = params['group_by'].present? && params['ordered_group_by'].present? ? params['ordered_group_by'].split(',') : ['issue']
    @grouping = params['group_by']
    @report_params = report_params
    @report = Reports::TimeReport.create_report(@report_params)
    respond_to do |format|
      format.js
      format.csv { send_data Reports::TimeReport.to_csv(@report), filename: 'timelog.csv' }
    end
  end

  private

  def report_params
    params.permit(:from, :to, :detail_by, :commit, :ordered_group_by, :group_by => [])
  end

  def default_params_date
    @from = Date.new(2018, 5, 1)
    @to = Date.new(2018, 5, 31)

    # @from = params[:from] || Date.today.beginning_of_month.to_s
    # @to = params[:to] || Date.today.to_s
  end


end
