class JiraController < ApplicationController

# will respond with head(:unauthorized) if verification fails
  before_action only: [:index] do |controller|
    controller.send(:verify_jwt, 'app-moc-report')
  end
  before_action :OAuth_access_token, only: [:index, :show]

  def index
    @form_params = Reports::TimeReport.create_form_params(current_jwt_auth.api_base_url, current_jwt_user.oauth_access_token)
  end

  def show
    params['group_by'] = params['group_by'].present? && params['ordered_group_by'].present? ? params['ordered_group_by'].split(',') : ['issue']
    if params['projects'].present?
      params['projects'] = params['projects'].split unless params['projects'].kind_of?(Array)
    end
    @grouping = params['group_by']
    @report_params = report_params
    @api_base_url = current_jwt_auth.api_base_url
    @report =  Reports::TimeReport.create_report(@report_params, @api_base_url, current_jwt_user.oauth_access_token)
    respond_to do |format|
      format.js
      format.csv { send_data Reports::TimeReport.to_csv(@report), filename: 'timelog.csv' }
    end
  end

  private

  def report_params
    params.permit(:from, :to, {projects: []}, {issue_types: []}, {assignees: []}, {statuses: []}, {group_by: []}, :ordered_group_by, :detail_by, :commit)
  end

end
