class JiraController < ApplicationController

  before_action :get_jira_client

  def initial_json
    # render json: AtlassianConnect::CONFIG.to_json
    render 'atlassian-connect.json'
  end

  def index
    #   @projectKey = params[:projectKey]
    @form_params = Reports::TimeReport.form_params

  end

  def show
    params['group_by'] =  params['group_by'] ? params['ordered_group_by'].split(',') : ['issue']
    @report = Reports::TimeReport.data(params)
    @periods = Reports::TimeReport.periods(@report, params['detail_by']) if @report
    p 'hhh'
    respond_to do |format|
      format.js
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
