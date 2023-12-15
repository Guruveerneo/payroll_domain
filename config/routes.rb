Rails.application.routes.draw do
 root 'sessions#new'

 resources :users do
  get 'salary_slip', on: :collection
  get 'view_salary_slip_details', on: :member
  post 'send_salary_slip_email', on: :member
end
  
  resources :sessions, only: [:new, :create, :destroy]
  resources :attendances, only: [:new, :create, :destroy]
  get 'attendances/calendar_view', to: 'attendances#calendar_view', as: :calendar_view
  get 'attendances/list_view', to: 'attendances#list_view', as: :list_view

resources :attendances do
  get :list_view, on: :collection
end

  get '/dashboard', to: 'dashboards#index', as: 'dashboard'
  delete '/logout', to: 'sessions#destroy', as: :destroy_user_session
end


