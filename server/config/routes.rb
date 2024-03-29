Rails.application.routes.draw do
  mount ActionCable.server => '/socket'

  match '*all', controller: 'application', action: 'cors_preflight_check', via: [:options]
  post 'login' => 'user_token#create'
  resources :tags, :users, :works, :notifications
  get '/users/:id/notifications', to: 'users#show_notifications'
  post '/users/:id/tags', to: 'users#create_tags'
  delete '/users/:id/tags/:tag_id', to: 'users#destroy_tags'
  post    '/works/:id/users', to: 'works#bind_participants'
  delete  '/works/:id/users/:user_id', to: 'works#unbound_participants'
  post    '/works/:id/tags', to: 'works#bind_tags'
  delete  '/works/:id/tags/:tag_id', to: 'works#unbound_tags'
end
