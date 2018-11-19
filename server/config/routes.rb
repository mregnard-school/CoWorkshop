Rails.application.routes.draw do
  post 'user_token' => 'user_token#create'
  resources :tags, :users, :works
  post '/users/:id/tags', to: 'users#create_tags'
  delete '/users/:id/tags/:tag_id', to: 'users#destroy_tags'
  post    '/works/:id/users', to: 'works#bind_participants'
  delete  '/works/:id/users/:user_id', to: 'works#unbound_participants'
  post    '/works/:id/tags', to: 'works#bind_tags'
  delete  '/works/:id/tags/:tag_id', to: 'works#unbound_tags'
end
