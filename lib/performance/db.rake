namespace :performance do
  namespace :db do
  
    desc "Reset database and re-populate it with production like data"
    task :reset => [:'db:data:sample_data', :'db:nuke_migrate_and_populate_data', :'performance:db:populate' ]    
    
    desc "Only resets the database if the migration or release1 data file has changed"
    task :reset_if_necessary do
      release_data = DB::Dataset.baseline_file
      sample_data = DB::Dataset.selected.file

      if new_migration? | 
         file_changed?(release_data) |
         file_changed?(sample_data) # keep these single |, not || - Dan
        Rake::Task["performance:db:reset"].invoke
      else
        puts "=== Skipping database reset." + "=" * 40
      end
    end
    
    desc "Populate database with production like data. Use 'rake performance:db:populate PERFORMANCE_GENERATOR_SCALE_FACTOR=100' for realistic data."
    task :populate => [:environment] do
      require File.dirname(__FILE__) + '/../../../db/performance_data_generator'
      factor = ENV['PERFORMANCE_GENERATOR_SCALE_FACTOR'] ? ENV['PERFORMANCE_GENERATOR_SCALE_FACTOR'].to_f : 1
      # tables.each do |table|
      #   table_count = (size_in_production_db(table) * factor).ceil
      # end
      display_counts = proc do
        local_variables.grep(/_count$/).each do |variable|
          count = eval(variable)
          puts "== %-25s %d" % [variable.chomp("_count"), count]
        end
      end
      display_counts.call
      puts "== Populating DB with production like data (x#{factor}) ========"
      PerformanceDataGenerator.new.generate_tables()
      display_counts.call
      puts
    end
  end
end
