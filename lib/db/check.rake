namespace :db do
  namespace :check do
    
    desc "Checks all."
    task :all => %w[environment db:check:foreign_keys db:check:engines]
    
    desc "Production."
    task :production => [:environment] do
      ActiveRecord::Base.clear_active_connections!
      ActiveRecord::Base.establish_connection :adapter => "mysql",
        :username => "name",
        :password => "password",
        :host => "localhost",
        :database => "database_name"
    end


    desc "Checks that we have some FOREIGN KEYS on our database."
    task :foreign_keys => [:environment] do
      number_of_foreign_keys = ActiveRecord::Base.connection.select_value(<<-EOS).to_i
        SELECT COUNT(1)
          FROM information_schema.table_constraints 
         WHERE table_schema = '#{ActiveRecord::Base.connection.instance_variable_get('@config')[:database]}'
           AND constraint_type = 'FOREIGN KEY' ORDER BY table_name, constraint_type;
        EOS
      db_config = ActiveRecord::Base.connection.instance_variable_get('@config')
      if number_of_foreign_keys < 100
        raise "where are the foreign keys? only have #{number_of_foreign_keys} in #{db_config[:database]} on #{db_config[:host]}"
      else
        puts "Found #{number_of_foreign_keys} foreign keys in #{db_config[:database]} on #{db_config[:host]}"
      end
      
      
      status = ActiveRecord::Base.connection.select_value(<<-EOS)
          SHOW INNODB STATUS;
        EOS
      
      raise "There were FOREIGN KEY constraint failures since last data insertion!\n\n#{status}" if status =~ /Foreign key constraint fails for table/
    end
    
    desc "Checks that we have all correct InnoDB engines in our database."
    task :engines => [:environment] do
      sql = <<-END
        SELECT table_name
          FROM information_schema.tables
         WHERE engine != 'InnoDB'
           AND table_schema = '#{ActiveRecord::Base.connection.instance_variable_get('@config')[:database]}'
           AND table_name NOT IN ('plugin_schema_info','schema_info')
      END
      non_inno_db_tables = ActiveRecord::Base.connection.select_values sql
      db_config = ActiveRecord::Base.connection.instance_variable_get('@config')
      if non_inno_db_tables.empty?
        puts "All tables are using InnoDB in #{db_config[:database]} on #{db_config[:host]}"
      else
        raise "Found MyISAM tables: #{non_inno_db_tables.join(', ')} in #{db_config[:database]} on #{db_config[:host]}"
      end
    end
    
    desc "Prints out invalid emails in a table"
    task :email_format => [:environment] do
      puts "please specify a table by using TABLE=table_name" and next unless ENV['TABLE']
      
      require File.join(RAILS_ROOT,'vendor','ruby-progressbar-0.9','progressbar')
      
      progress = nil
      invalid_emails = EmailAddressFormatVerifier.find_invalid_emails(ENV['TABLE']) do |batch, total_batches|
        progress ||= ProgressBar.new(ENV['TABLE'],total_batches)
        progress.inc
      end
      progress.finish
      puts "---- invalid emails from in #{ENV['TABLE']} ----"
      invalid_emails.each do |id, email|
        puts "#{id}, #{email}" unless email.nil?
      end
    end
  end
end
