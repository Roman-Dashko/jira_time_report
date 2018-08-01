class JiraController < ApplicationController

# will respond with head(:unauthorized) if verification fails
#   before_action only: [:index] do |controller|
#     controller.send(:verify_jwt, 'app-moc-report')
#   end

  def index
    # request_OAuth_access_token
    @form_params = form_params
  end

  def show

    params['group_by'] = params['group_by'].present? ? params['ordered_group_by'].split(',') : ['issue']
    @report = data(params)
    @periods = periods(@report, params['detail_by']) if @report.present?
    p 'hhh'
    respond_to do |format|
      format.js
      format.csv { send_data Acc::GeneralReport.to_csv(@report), filename: 'timelog.csv' }
    end

  end

  private

  def default_params_date
    @from = Date.new(2018, 5, 1)
    @to = Date.new(2018, 5, 31)

    # @from = params[:from] || Date.today.beginning_of_month.to_s
    # @to = params[:to] || Date.today.to_s
  end


end
