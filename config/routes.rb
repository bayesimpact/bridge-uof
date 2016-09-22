Rails.application.routes.draw do
  resource :screener, only: [:new, :create], path_names: { new: "" }

  resources :incidents, except: [:index, :create, :edit] do
    resource :general_info, only: [:update, :edit], path_names: { edit: "" }
    resources :involved_civilians, except: :show
    resources :involved_officers, except: :show

    member do
      get 'review'
    end

    collection do
      match 'upload', via: [:get, :post]
      post 'create_fake' if Rails.configuration.x.login.use_demo?
    end
  end

  controller :incidents do
    get 'dashboard(/:status(/:year))' => :index, as: 'dashboard'
    post 'dashboard' => :submit_to_state!

    get 'incidents.json' => :json
  end

  controller :doj do
    get 'doj' => :overview
    get 'doj/overview' => :overview
    get 'doj/window' => :window
    post 'doj/window' => :window_toggle
    get 'doj/whosubmitted' => :whosubmitted
    get 'doj/incidents(/:ori)' => :incidents
    get 'doj/analysis' => :analysis
  end

  controller :feedback do
    get 'feedback' => :new
    post 'feedback' => :create
    get 'thank_you' => :thank_you
  end

  controller :splash do
    get 'welcome' => :splash_show
    post 'welcome' => :splash_dismiss
  end

  controller :monitoring do
    get 'ping' => :ping
    get 'ping.html' => :ping
  end

  root to: "incidents#index"

  if Rails.configuration.x.login.use_devise?
    devise_for :users, controllers: { sessions: 'users/sessions' }
  elsif Rails.configuration.x.login.use_demo?
    post 'reset_demo' => "application#reset_demo!"
  end
end
