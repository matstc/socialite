Socialite::Application.routes.draw do

  devise_for :users

  match 'submissions/:id/vote_up', :to => 'submissions#vote_up', :via => "post", :defaults => { :format => 'js'}, :as => 'vote_up'
  match 'about', :to => "application#about", :via => "get", :as => 'about'
  match 'users/best_of', :to => "users#best_of", :via => "get", :as => "best_of_users"
  match 'best_of', :to => "submissions#best_of", :via => "get", :as => 'best_of_submissions'
  match 'new', :to => "submissions#most_recent", :via => "get", :as => 'new'
  match 'stats', :to => "statistics#index", :via => "get", :as => 'statistics'

  get 'admin', :to => "admin#index", :as => 'admin'

  get 'sign_in_then_redirect', :to => "application#sign_in_then_redirect"

  match 'admin/raise_dummy_error', :to => "admin#raise_dummy_error"

  match 'admin/moderate/submissions', :to => "admin#moderate_submissions", :via => "get", :as => 'moderate_submissions'
  match 'admin/moderate/comments', :to => "admin#moderate_comments", :via => "get", :as => 'moderate_comments'

  match 'admin/email_settings', :to => "admin#email_settings", :via => "get", :as => 'email_settings'
  match 'admin/save_email_settings', :to => "admin#save_email_settings", :via => "post", :as => 'save_email_settings'

  match 'admin/automatic_notifications', :to => "admin#automatic_notifications", :via => "get", :as => 'automatic_notifications'
  match 'admin/save_automatic_notifications', :to => "admin#save_automatic_notifications", :via => "post", :as => 'save_automatic_notifications'

  match 'admin/send_test_email', :to => "admin#send_test_email", :via => "post", :as => 'send_test_email'
  match 'admin/test_exception_notifier', :to => "admin#test_exception_notifier", :via => "post", :as => 'test_exception_notifier'

  match 'admin/change_name', :to => "admin#change_name", :via => "get", :as => 'change_name'
  match 'admin/save_app_name', :to => "admin#save_app_name", :via => "post", :as => 'save_app_name'

  match 'admin/setup_google_analytics', :to => "admin#setup_google_analytics", :via => "get", :as => 'setup_google_analytics'
  match 'admin/save_google_analytics', :to => "admin#save_google_analytics", :via => "post", :as => 'save_google_analytics'

  match 'admin/tweak_interestingness', :to => "admin#tweak_interestingness", :via => "get", :as => 'tweak_interestingness'
  match 'admin/save_interestingness', :to => "admin#save_interestingness", :via => "post", :as => 'save_interestingness'

  match 'admin/modify_appearance', :to => "admin#modify_appearance", :via => "get", :as => 'modify_appearance'
  match 'admin/save_appearance', :to => "admin#save_appearance", :via => "post", :as => 'save_appearance'

  match 'admin/modify_about_page', :to => "admin#modify_about_page", :via => "get", :as => 'modify_about_page'
  match 'admin/save_about_page', :to => "admin#save_about_page", :via => "post", :as => 'save_about_page'

  match 'admin/mark_submission_as_spam', :to => "admin#mark_submission_as_spam", :as => 'mark_submission_as_spam'
  match 'admin/undo_mark_submission_as_spam', :to => "admin#undo_mark_submission_as_spam", :as => 'undo_mark_submission_as_spam'

  match 'admin/mark_comment_as_spam', :to => "admin#mark_comment_as_spam", :as => 'mark_comment_as_spam'
  match 'admin/undo_mark_comment_as_spam', :to => "admin#undo_mark_comment_as_spam", :as => 'undo_mark_comment_as_spam'

  scope "/admin" do
    match 'spammers', :controller => 'users', :action => 'spammers', :via => "get", :as => 'spammers'
    resource :logo, :only => [:new, :create]
    resource :favicon, :only => [:create]
  end

  resources :reply_notification, :only => [:destroy]
  resources :spam_notification, :only => [:destroy]
  match 'reply_notifications/dismiss_all', :to => 'reply_notification#dismiss_all', :via => "delete", :as => 'dismiss_all_notifications'
  match 'spam_notifications/dismiss_all', :to => 'spam_notification#dismiss_all', :via => "delete", :as => 'dismiss_all_spam_notifications'

  resources :users
  match 'users/:id/comments', :controller => 'users', :action => 'show_comments', :via => "get", :as => 'user_comments'
  match 'users/:id/submissions', :controller => 'users', :action => 'show_submissions', :via => "get", :as => 'user_submissions'

  resources :submissions

  # keep this line below the declaration of submissions as resources to keep RSS out of pagination
  match 'submissions.rss', :to => 'submissions#index', :via => "get", :format => 'rss', :as => 'popular_page_rss'

  resources :comments

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
  root :to => "submissions#index"

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
end
