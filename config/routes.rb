Rails.application.routes.draw do
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  root to: 'dashboard#index'

  scope '/', defaults: { format: :html }, constraints: { format: :html } do
    delete 'users/stop_masquerading'
    resources :users, except: [:new] do
      post 'masquerade'
    end
    resources :groups
    resources :messages, only: :index
    resources :roles
    get 'login' => 'login#index'
    post 'login' => 'login#verify'
    delete 'login' => 'login#logout'
  end

  scope :api, defaults: { format: :json }, constraints: { format: :json } do
    scope :v1 do
      resources :group_memberships, only: [:destroy, :create]
      resources :users, except: [:new, :edit] do
        get 'group_memberships' => 'users#group_memberships'
      end
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
