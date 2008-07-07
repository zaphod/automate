namespace :performance do
  namespace :test do
    desc "Run controller functional tests for performance"
    Rake::TestTask.new(:actions => [:'migrate_performance_db']) do |t|
      t.test_files = FileList.new('test/suites/performance/actions/**/*_test.rb', 'test/suites/performance/workers/**/*_test.rb')
    end
    
    desc "Migrate the performance_test database"
    task :migrate_performance_db do
      RAILS_ENV = 'test'
      DB_SCHEMA_BASE = 'performance'
      Rake::Task[:'db:migrate'].invoke
    end
  end
end
