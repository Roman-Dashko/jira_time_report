class ApplicationController < ActionController::Base

  private

  def get_jira_client
	options = {
	  :username     => 'testtost2018',
	  :password     => 'zzz123456789',
	  :site         => 'http://romand.atlassian.net:443/',
	  :context_path => '',
	  :auth_type    => :basic
	}

	@jira_client = JIRA::Client.new(options)
  end
end
