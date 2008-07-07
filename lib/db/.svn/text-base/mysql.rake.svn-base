require 'active_record'
require 'erb'
require 'yaml'

namespace :db do
  
  task :restart do
    `mysqladmin shutdown -u root`
    `sudo mysqld_safe &`
  end

  desc("Recreate test and development databases from scratch")
  task :create => :environment do
    [ "development", "test"].each do |environment|
      configuration = DB::MySQL::DatabaseConfiguration.configuration_for_env(environment)
      database = DB::MySQL::Database.new(configuration, '-u root')
      database.recreate
    end
  end  
  
end

desc "Loads MySQL command prompt"
task :mysql do
  puts "\n\nLoading mysql in RAILS_ENV=#{RAILS_ENV}...\n"

  configuration = DB::MySQL::DatabaseConfiguration.configuration_for_env(RAILS_ENV)
  
  command = []
  command << "mysql #{configuration.mysql_command_line_connection}"
  
  puts <<-EOS
    Executing: #{command.join(' ')}\n
  EOS

  system command.join(' ')
end
