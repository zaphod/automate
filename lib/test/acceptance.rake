namespace :test do
  namespace :acceptance do
    
    desc("set up host and port ENV variables for acceptance tests")
    task :environment do
      ENV['SELENIUM_APPLICATION_HOST'] = 'APPLICATION_HOST'
      ENV['SELENIUM_APPLICATION_BASE_PORT'] = "5000"
      ENV['APP_CAP_ENVIRONMENT'] = "production"
    end
    
    desc("Run selenium test suite on Firefox")
    task :firefox do 
      ENV['SELENIUM_BROWSER'] = '*chrome'
      ENV['SELENIUM_REMOTE_CONTROL'] = 'selenium_grid'
      
      Rake::Task[:'test:acceptance:run_tests_in_parallel'].invoke
    end

    desc("Run selenium tests in parallel")
    task :run_tests_in_parallel => :environment do
      runner = MultiProcessSpecRunner.new(15)
      runner.run(
        Dir["test/suites/acceptance/**/spec_*.rb"],
          ENV['SELENIUM_APPLICATION_HOST'],
          ENV['SELENIUM_APPLICATION_BASE_PORT'].to_i
      )
    end
  end  
end
