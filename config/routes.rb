Rails.application.routes.draw do
 root 'sessions#new'
  resources :users
  resources :sessions, only: [:new, :create, :destroy]
  resources :attendances, only: [:new, :create, :destroy]
  # resources :attendances do
#   collection do
#     get 'calendar_view'
#     get 'list_view'
#   end
# end

get 'attendances/calendar_view', to: 'attendances#calendar_view', as: :calendar_view
get 'attendances/list_view', to: 'attendances#list_view', as: :list_view

resources :attendances do
  get :list_view, on: :collection
end


  
  # resources :attendances, only: [] do
  #   collection do
  #      get 'upload'
  #   post 'upload'
  #   end
  # end
  
  get '/dashboard', to: 'dashboards#index', as: 'dashboard'
  delete '/logout', to: 'sessions#destroy', as: :destroy_user_session
end
