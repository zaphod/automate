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
