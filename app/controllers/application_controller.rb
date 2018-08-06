class ApplicationController < ActionController::Base

	include AtlassianJwtAuthenticationMOC::Filters
	include AtlassianJwtAuthenticationMOC::Helper

	protect_from_forgery with: :null_session

	# before_action :on_add_on_installed, only: [:installed]
	# before_action :on_add_on_uninstalled, only: [:uninstalled]

	def initial_json
		render 'atlassian-connect.json'
	end

	def installed
		on_add_on_installed
		# render head :ok
	end

	def uninstalled
    # on_add_on_uninstalled
		# render head :ok
	end

end
