Rails.application.routes.draw do
  
  cullender_for :events
  resources :events
end
