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
      accounts_count = (150_000 * factor).ceil
      accounts_crm_contacts_count = (500_000 * factor).ceil
      account_privileges_count = (300_000 * factor).ceil
      buyer_groups_count = (500 * factor).ceil
      buyer_group_memberships_count = (150_000 * factor).ceil
      crm_contacts_count = (500_000 * factor).ceil
      listings_count = (500_000 * factor).ceil
      users_count = (150_000 * factor).ceil
      vehicles_count = (500_000 * factor).ceil # number needs to be 1.5 - 2 million
      parking_lot_listings_count = (1_000 * factor).ceil
      display_counts = proc do
        local_variables.grep(/_count$/).each do |variable|
          count = eval(variable)
          puts "== %-25s %d" % [variable.chomp("_count"), count]
        end
      end
      display_counts.call
      puts "== Populating DB with production like data (x#{factor}) ========"
      PerformanceDataGenerator.new.generate_crm_contacts(crm_contacts_count) # extras not associated with users
      PerformanceDataGenerator.new.generate_accounts(accounts_count)
      PerformanceDataGenerator.new.generate_accounts_crm_contacts(accounts_crm_contacts_count)
      PerformanceDataGenerator.new.generate_users(users_count)
      PerformanceDataGenerator.new.generate_account_privileges(account_privileges_count)
      PerformanceDataGenerator.new.generate_buyer_groups(buyer_groups_count)
      PerformanceDataGenerator.new.generate_buyer_group_memberships(buyer_group_memberships_count)
      PerformanceDataGenerator.new.generate_listings(listings_count)
      PerformanceDataGenerator.new.generate_parking_lot_passenger_vehicles(vehicles_count)
      PerformanceDataGenerator.new.generate_parking_lot_listings(parking_lot_listings_count)
      PerformanceDataGenerator.new.generate_equipment_listings
      display_counts.call
      puts
    end
  end
end
