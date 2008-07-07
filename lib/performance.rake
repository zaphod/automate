namespace :performance do
  desc "Run httperf for all performance scenari"
  task :httperf do
    sh "ruby #{RAILS_ROOT}/test/suites/performance/httperf -n 20 -n all -s performance_website_url -p 3080"   
  end
end
