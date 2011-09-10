Socialite::Application.configure do
  if AppSettings.table_exists?
    require 'app/helpers/application_helper'
    require 'exception_notifier'
    include ApplicationHelper

    setup_omniauth
  end
end

