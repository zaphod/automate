namespace :performance do
  namespace :metrics do
    
    desc "Harvest performance metrics"
    task :harvest do
      output_path = ENV['CC_BUILD_ARTIFACTS'] || (RAILS_ROOT + "/log")
      sh "#{RUBY} #{RAILS_ROOT}/lib/generate_performance_summary.rb > #{output_path}/performance_metrics"
      system "#{RUBY} #{RAILS_ROOT}/script/check_routes_coverage.rb >> #{output_path}/performance_metrics"
      if ENV['CC_BUILD_ARTIFACTS']
        sh "cp #{RAILS_ROOT}/log/test.log #{ENV['CC_BUILD_ARTIFACTS']}/raw_performance_log"
      end
    end
    
    task :generate => ["log:clear"] do
      begin
        # Rake::Task["performance:db:reset_if_necessary"].invoke
        Rake::Task["performance:test:actions"].invoke
      ensure
        Rake::Task["performance:metrics:harvest"].invoke
      end
    end        
  end
end
