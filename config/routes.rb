Rails.application.routes.draw do
  get '/jira' => 'jira#index'
  get '/jira/initial_json' => 'jira#initial_json'
  get '/jira/show' => 'jira#show'

  root 'jira#initial_json'
end
