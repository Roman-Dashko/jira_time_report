class JiraController < ApplicationController

  before_action :get_jira_client

  def index
    @id = params[:id]
    @type = params[:type]
  end

  def initial_json
    # render json: AtlassianConnect::CONFIG.to_json
    render 'atlassian-connect.json'
  end

  def helloworld; end

  def report
    # projects = @jira_client.Project.all
	#
    # projects.each do |project|
    #   puts "Project -> key: #{project.key}, name: #{project.name}"
    # end

    # @projectKey = params[:projectKey]
    @projectKey = 'ST'
    @project = @jira_client.Project.find(@projectKey)
    # @project.issues.each do |issue|
    #   puts "#{issue.key} - #{issue.summary}"
    #   issue.worklogs.each do |worklog|
    #     puts "#{worklog.key} - #{issue.summary}"
    #   end
    # end

    # issue = @jira_client.Issue.find('ST-1')
    # @project.issues.each do |_issue|
    #   issue = @jira_client.Issue.find(_issue.key)
    #   if issue.respond_to?(:timetracking)
    #     puts "#{issue.key} - #{issue&.timetracking['remainingEstimate']} - #{issue&.timetracking['timeSpent']}"
    #   else
    #     puts "#{issue.key} - no - no"
    #   end
    #   issue.worklogs.each do |worklog|
    #     worklog_comment = worklog.respond_to?(:comment) ? worklog.comment : 'no comments'
    #     puts "    #{worklog.id} - #{worklog_comment} - #{worklog.timeSpent}"
    #   end
    # end
  end
end
