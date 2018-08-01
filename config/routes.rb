Rails.application.routes.draw do
  get '/jira' => 'jira#index'
  get '/jira/show' => 'jira#show'
  get '/jira/initial_json' => 'jira#initial_json'
  post '/jira/installed' => 'jira#installed'
  post '/jira/uninstalled' => 'jira#uninstalled'

  root 'jira#initial_json'
end
