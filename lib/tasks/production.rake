namespace :production do
  def in_production &block
    old_environment = Rails.env
    Rails.env = 'production'
    yield
    Rails.env = old_environment
  end

  def initialize_app
    require File.expand_path("../../../config/environment", __FILE__)
  end

  desc 'Creates a new secret token to hash cookies'
  task :secret do |t|
    puts "Creating a secret token for your application..."
    secret = ActiveSupport::SecureRandom.hex(64)
    secret_token_file = File.expand_path("../../../config/initializers/secret_token.rb", __FILE__)
    puts "Your old secret_token.rb file used to read: #{File.open(secret_token_file).read}"

    File.open(secret_token_file, 'w') do | file |
      contents =<<EOD
# this secret token was generated automatically by the rake task '#{t.name}'
Socialite::Application.config.secret_token = '#{secret}'
EOD
      file.write contents
    end
    puts "Your new secret token file now reads: #{File.open(secret_token_file).read}"
  end

  namespace :admin do
    desc 'Creates an administrator user in production'
    task :create, [:username, :password] => 'db:create' do |t, args|
      in_production do
        username = args['username']
        password = args['password']
        example_password = "s3cr3t"

        if username.blank? || password.blank?
          raise "Please specify a username and a password for the initial administrator (e.g. rake #{t.name}[admin,#{example_password}])"
        end

        if password == example_password
          raise "Please use a different password than #{example_password} :)"
        end

        puts "Creating an admin user with username of #{username} and password #{password}..."
        initialize_app
        admin = User.new :username => username, :password => password, :password_confirmation => password, :email => "admin@localhost.localhost", :confirmed_at => Time.now
        admin.save!
        admin.update_attribute :admin, true
      end
    end
  end

  desc 'Creates a blank production database with the proper schema'
  namespace :db do
    task :create do
      in_production do
        puts "Creating a blank production database..."
        Rake::Task['db:create'].invoke
        Rake::Task['db:migrate'].invoke
      end
    end
  end

  desc 'Initializes the production database for first deployment'
  task :initialize, [:admin_username, :admin_password] do |t, args|
    Rake::Task['production:admin:create'].invoke(args['admin_username'], args['admin_password'])
    Rake::Task['production:secret'].invoke

    puts "--"
    puts "Your production environment is now ready."
    puts "You can start it by typing:\n\n> thin start -e production\n\n"
  end

end
