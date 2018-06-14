Rails.application.routes.draw do
  get '/jira' => 'jira#index'
  get '/jira/initial_json' => 'jira#initial_json'
  get '/jira/helloworld' => 'jira#helloworld'
  get '/jira/report' => 'jira#report'

  get 'welcome/index'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root 'welcome#index'
end
