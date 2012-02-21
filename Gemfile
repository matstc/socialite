source 'http://rubygems.org'

gem 'rails', '3.0.5'
# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

gem 'sqlite3'

# authentication
gem 'devise'

gem 'exception_notification', :path => 'vendor/gems/exception_notification-2.4.0'

gem 'hpricot', :group => :development
gem 'ruby_parser', :group => :development
gem 'haml'
gem "rails-settings", :path => "vendor/gems/rails-settings"
gem 'kaminari', '0.13'  #pagination
gem 'thin'

# spam filtering
# this gem makes rake db:seed fail so we froze it and edited the vector.rb file in it
gem 'classifier',  :path => "vendor/gems/classifier-1.3.3"
gem 'fast-stemmer'
gem 'madeleine'

# Bundle gems for the local environment. Make sure to
# put test-only gems in this group so their generators
# and rake tasks are available in development mode:
group :development, :test do
  gem 'rspec-rails', '2.8'
  gem 'ruby-debug'
  gem 'rcov'
end

gem 'haml-rails', :group => :development

gem 'omniauth' # try the following command line on ubuntu if you have trouble installing the nokogori gem (a dependency of omniauth) and its native extensions: sudo apt-get install libxslt1-dev
gem 'twitter'

gem 'bitly'
