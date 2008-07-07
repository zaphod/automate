namespace :db do

  namespace :snapshot do

    desc "Create a snapshot of the dev database for easy restore"
    task :create do

      puts "Creating db snapshot."

      config = DB::MySQL::DatabaseConfiguration.configuration_for_env(RAILS_ENV)

      command = []
      command << "mysqldump #{config.mysql_command_line_connection}"
      command << "> #{RAILS_ROOT}/tmp/#{RAILS_ENV}.mysqldump"

      sh command.join(' ')
    end

    desc "Restore database snapshot"
    task :restore do
      config = DB::MySQL::DatabaseConfiguration.configuration_for_env(RAILS_ENV)

      command = []
      command << "mysql #{config.mysql_command_line_connection}"
      command << "< #{RAILS_ROOT}/tmp/#{RAILS_ENV}.mysqldump"

      sh command.join(' ')
    end

  end  
end
