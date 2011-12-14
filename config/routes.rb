DebateApp::Application.routes.draw do
  
  get "judgings/index"
  # 
  # get "judgings/create"
  
  match 'judgings/create/:debate_id/' => 'judgings#create'
  match 'judgings/:id/submission' => 'judgings#submission'
  resources :judgings do
    member do 
      get 'submission'
    end
  end

  # CAN GET RID OF
  # get "topic_positions/create"
  # 
  # get "topic_positions/destroy"
  
  resources :topic_positions do
    member do 
      get 'matches'
    end
  end

  get "pages/landing"

  match 'debates/:debate_id/leaving' => 'viewings#leaving_page'
  match 'debaters/:debater_id/trackings/leaving' => 'viewings#leaving_page'

  devise_for :debaters, :controllers => {:omniauth_callbacks => "debaters/omniauth_callbacks"}

  # RICK--IS THIS NESTED IN A NAMESPACE FOR SOME REASON?
  # namespace :debater do
  #   root :to => "pages#landing"
  # end
  root :to => "pages#landing"

  resources :votes, :only => :create

  resources :debaters, :only => [:new, :create, :show] do
    resources :trackings, :only => [:index, :new, :create, :destroy]
  end
  
  resources :debaters do
    member do
      get :following, :teammates, :followers, :is_blocking, :blockers
    end
  end
  
  resources :debates do
    member do
  	  post 'join'
  	end
  end
  
  resources :arguments
  resources :relationships, :only => [:create, :destroy]
  resources :blockings, :only => [:create, :destroy] do
    collection do
      post 'borrow'
    end
  end
  
  root :to => 'debates#index'
  
  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
end
