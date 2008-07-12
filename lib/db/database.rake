namespace :db do
  
  desc "Show the db diff for the day"
  task :diff do
    sh %Q(svn diff -r "{#{Time.now.strftime('%Y-%m-%d')}}":"{#{1.day.from_now.strftime('%Y-%m-%d')}}" db/migrate/reference_data.rb)
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
    system "mysqldump -u root --no-create-info --complete-insert --single-transaction database_name > ../performance_dump.sql"
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
