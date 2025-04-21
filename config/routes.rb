Rails.application.routes.draw do
  get "borrowings/index"
  root 'books#index'

  resources :borrowings, only: [:index]

  resources :authors
  resources :categories


  resources :users, only: [:new, :create] do
    patch 'update_avatar', on: :member  # 处理更新头像的路径
  end
  # 书籍相关
  resources :books, only: [:index, :show, :new, :create, :edit, :update, :destroy] do
    collection do
      get 'search' # 搜索功能
    end
    member do
      post 'borrow' # 借阅功能
      post 'return' # 还书
    end
  end

  resources :sessions, only: [:new, :create, :destroy]

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"
end
