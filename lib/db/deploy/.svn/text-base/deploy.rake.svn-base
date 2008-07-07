namespace :db do
  namespace :deploy do

    desc "Deletes existing schema and loads depot schema, then runs db:migrate"
    task :reset_schema => %w[environment create_snapshot db:nuke db:depot:load_tables db:migrate]

    desc "Ensure a dataset has be selected, rather than using default"
    task :explicitly_selected_dataset do
      raise "DATASET parameter needed. eg. sample_data" unless ENV['DATASET']
    end
    
    desc "Loads schema with all depot data, zip & dmas, release 1 data, and specified dataset"
    task :load_dataset => %w[environment explicitly_selected_dataset db:load_source_data db:load_ruby_reference_data db:depot:load_data] do
      # Loading release 1 data and ENV['DATASET']
      DB::Dataset.selected.load
    end
      
    desc "Reset and load dataset"
    task :reset_and_load_dataset => %w[reset_schema load_dataset]
    
    desc "Reset and load reference data(zips and dmas and ruby reference data)"
    task :reset_and_load_ruby_reference_data => %w[reset_schema db:load_source_data db:load_ruby_reference_data]
    
    desc "Create a snapshot of the database for easy restore"
    task :create_snapshot do
      puts "Creating #{RAILS_ENV} db snapshot."

      config = DB::MySQL::DatabaseConfiguration.configuration_for_env(RAILS_ENV)

      command = []
      command << "mysqldump #{config.mysql_command_line_connection}"
      command << "> #{RAILS_ROOT}/tmp/#{RAILS_ENV}.mysqldump"

      sh command.join(' ')
    end

    desc "Restore database snapshot"
    task :restore_snapshot do
      config = DB::MySQL::DatabaseConfiguration.configuration_for_env(RAILS_ENV)

      command = []
      command << "mysql #{config.mysql_command_line_connection}"
      command << "< #{RAILS_ROOT}/tmp/#{RAILS_ENV}.mysqldump"

      sh command.join(' ')
    end
    
  end
  
end

