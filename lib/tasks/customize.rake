namespace :customize do
  desc 'Creates the necessary files for a new theme'
  task :theme, [:name] do |t, args|
    name = args[:name]
    if name.nil?
      raise "You need to specify the name of the new theme (e.g. rake customize:theme[awesome])"
    end

    require 'app/helpers/application_helper'
    include ApplicationHelper

    directory = theme_directory name
    theme_file = theme_file name

    Dir.mkdir directory
    FileUtils.touch theme_file

    puts "Edit the following file to create your custom theme: #{theme_file}"
    puts "Then log into your app as admin and change the theme to '#{name}' in the admin section."
    puts "You should then see your new theme in action."
  end
end
