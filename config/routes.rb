Rails.application.routes.draw do
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  root to: 'dashboard#index'
  resources :users

  scope '/', defaults: { format: :html }, constraints: { format: :html } do
    resources :groups do
      resources :users
    end
    resources :users, except: [:new]
    resources :messages, only: :index
    resources :roles
    get 'login' => 'login#index'
    post 'login' => 'login#verify'
    delete 'login' => 'login#logout'
  end

  scope :api, defaults: { format: :json }, constraints: { format: :json } do
    scope :v1 do
      resources :users, except: [:new, :edit]
      get 'messages/recipients' => 'messages#search_recipients'
      resources :messages, except: [:new, :edit]
      resources :groups, except: [:new, :edit] do
        get 'users' => 'groups#users'
      end
      resources :roles, except: [:new, :edit] do
        get 'users' => 'roles#users'
        resources :role_memberships, only: [:create, :destroy]
      end
    end
  end
end
