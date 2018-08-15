class ApplicationController < ActionController::Base

	include AtlassianJwtAuthentication::Filters
	include AtlassianJwtAuthentication::Helper

	protect_from_forgery with: :null_session

	before_action :on_add_on_installed, only: [:installed]
	before_action :on_add_on_uninstalled, only: [:uninstalled]

	def initial_json
		render 'atlassian-connect.json'
	end

	def installed
	end

	def uninstalled
	end

end
