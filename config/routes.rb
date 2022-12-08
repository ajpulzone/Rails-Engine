Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  namespace :api do
    namespace :v1 do
      resources :merchants do
        resources :items, only: [:index], controller: "merchant_items"
      end 
      resources :items do
        resources :merchant, only: [:index], controller: "item_merchants"
      end
      resources :invoices
    end
  end
end
