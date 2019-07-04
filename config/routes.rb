Rails.application.routes.draw do
  root 'home#index'

  get :healthcheck, controller: :healthcheck, action: :show
end
