require 'active_record'
require 'benchmark'
require 'erb'
require 'yaml'

namespace :db do

  namespace :ci do
    desc "Migrates down and up for check in without loading development data"
    task :prepare => [:environment, :'db:nuke', :'db:migrate']
  end
  
  task :load_ruby_reference_data do
    # load "#{RAILS_ROOT}/db/data/reference_data.rb"
  end

  desc "drop and re-create the database"
  task :nuke => [:environment] do
    ActiveRecord::Base::connection.execute("drop schema #{ActiveRecord::Base.configurations[RAILS_ENV]["database"]}")
    ActiveRecord::Base::connection.execute("create schema #{ActiveRecord::Base.configurations[RAILS_ENV]["database"]} character set utf8")
    ActiveRecord::Base.clear_active_connections!
  end

  desc "Nuke, migrate, populate data"
  task :nuke_migrate_and_populate_data => %w[db:reset_with_only_ruby_reference_data db:depot:load_data db:populate_test_data db:snapshot:create]
  task :nmap => :nuke_migrate_and_populate_data

	desc "Populate test data into the database."
	task :populate_test_data => [:environment, :'db:migrate', :'services:stub_all'] do
	  require 'db/dataset'
	  dataset = DB::Dataset.selected
	  total = Benchmark.measure {dataset.load}
  	puts "\n== Dataset #{dataset.name}: #{total}"
	end

  desc "Reset development and testing database"
  task :reset => %w[db:nuke_migrate_and_populate_data db:test:prepare insert_factory_defaults]

  desc "Only resets the database if the migration or reference data file has changed"
  task :reset_if_necessary do
    reference_data = DB::Dataset.baseline_file
    selected_dataset = DB::Dataset.selected.file
    
    if new_migration? | 
       file_changed?(reference_data) |
       file_changed?(selected_dataset) # keep these single |, not || - Dan
      Rake::Task["db:nuke_migrate_and_populate_data"].invoke
    else
      puts "=== Skipping database reset." + "=" * 40
    end
  end
  
  desc "Reset with only Ruby reference data"
  task :reset_with_only_ruby_reference_data => %w[environment db:nuke db:depot:load_tables db:migrate db:load_source_data db:load_ruby_reference_data]

  desc "SELECT COUNT(1) on all tables"
  task :table_counts => :environment do
    include ActionView::Helpers::NumberHelper
    ActiveRecord::Base.connection.tables.sort.each { |table| puts "%40s: %s" % [table.ljust(35, '.'), number_with_delimiter(ActiveRecord::Base.connection.select_one('SELECT COUNT(1) FROM ' + table).values.first).rjust(10, ' ')] }
  end

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
  
  desc "Generate more human readable db schema"
  task :readable => :environment do
    migration_file = File.expand_path(File.join(RAILS_ROOT, 'db', 'migrate', 'reference_data.rb'))
    migration = File.read migration_file
    migration = migration.match(/self.up/).post_match
    migration.gsub! /create_table/, 'table'
    migration.gsub! /t.column\s*/, ''
    migration.gsub! /,\s*:force\s*=>\s*true/, ''
    migration.gsub! /\s*do\s*\|t\|\s*$/, ''
    migration.gsub! /:/, ''
    migration.gsub! /string,?/, ''
    migration.gsub! /integer,?/, ''
    migration.gsub! /boolean,?/, ''
    migration.gsub! /datetime,?/, ''
    migration.gsub! /,\s+$/, ''
    puts migration
  end
  
  desc "Trucate all tables"
  task :truncate_all => :environment do
    print "All data is about to be truncated, is this what you want? [y/N]"
    $stdout.flush
    confirmation = $stdin.gets
    puts
    if confirmation.chomp.downcase == "y"
      conn = ActiveRecord::Base.connection
      begin
        puts "Truncating all data."
        conn.execute "set foreign_key_checks=0"
        conn.tables.each {|t| conn.execute "truncate #{t}"}
      ensure
        conn.execute "set foreign_key_checks=1"
      end
    else
      puts "Then don't do rake db:truncate_all next time"
    end
  end
  
  desc "Dump image for performance"
  task :dump_performance do
    system "mysqldump -u root --no-create-info --complete-insert --single-transaction DEVELOPMENT_DATABASE > ../performance_dump.sql"
    contents = File.read('../performance_dump.sql')
    File.open("../performance_dump.sql","w") do |file|
      file << <<-end_sql
DROP TRIGGER IF EXISTS `listings_audit_ai`;
DROP TRIGGER IF EXISTS `listings_audit_au`;       
      end_sql
      
      file << contents
    end
  end
  
  desc "Validate database"
  task :run_validations => :environment do
    system "echo 'USAGE: rake db:run_validations RAILS_ENV=<env> model=<ModelName> id=<id>'"
    system "ruby #{RAILS_ROOT}/script/validate_data.rb #{RAILS_ENV}"
  end
  
end

def file_changed?(file)
  md5_cache = file + ".md5"
  current_md5 = case RUBY_PLATFORM
    when /darwin/
      `md5 -q #{file}`
    when /linux/
      `md5sum #{file} | awk '{print $1}'`
    else
      "cannot determine md5 hash, always reset: #{rand}"
  end.strip
  cached_md5 = File.exists?(md5_cache) ? File.read(md5_cache).strip : ""
  return false if cached_md5 == current_md5
  File.open(md5_cache, 'w') { |file| file.write current_md5 }
  true
end

def new_migration?
  last_migration_cache = File.join(RAILS_ROOT, "db", "migrate", "last_migration.txt")
  current_last_migration = Dir.glob("#{RAILS_ROOT}/db/migrate/*.rb").sort.last.strip
  last_migration_ran = File.exists?(last_migration_cache) ? File.read(last_migration_cache).strip : ""
  return false if last_migration_ran == current_last_migration
  File.open(last_migration_cache, "w") { |file| file.write current_last_migration }
  true
end
