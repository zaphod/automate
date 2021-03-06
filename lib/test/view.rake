namespace :test do
  namespace :view do
    
    task :environment do
      ENV['SELENIUM_APPLICATION_HOST'] = "APPLICATION_HOST"
      ENV['SELENIUM_APPLICATION_BASE_PORT'] = "5000"
      ENV['APP_CAP_ENVIRONMENT'] = "IPADDRESS"
    end    

    task :firefox do 
      ENV['SELENIUM_BROWSER'] = '*chrome'
      ENV['SELENIUM_REMOTE_CONTROL'] = 'IPADDRESS'
      
      Rake::Task[:'test:view:run_tests_in_parallel'].invoke
    end

    task :run_tests_in_parallel => :environment do
      runner = MultiProcessSpecRunner.new(15)
      runner.run(
        Dir["test/suites/view/**/*_test.rb"],
        ENV['SELENIUM_APPLICATION_HOST'],
        ENV['SELENIUM_APPLICATION_BASE_PORT'].to_i
      )
    end
    
  end  
end
