Rake::Task[:test].prerequisites.clear
Rake::Task[:test].enhance %w[test:unit deep_test:functional]

namespace :test do
  
  Rake::TestTask.new(:run_smoke => "db:test:load") do |t|
    t.libs << "test"
    t.pattern = 'test/ruby_selenium/smoke/**/smoke_*.rb'
    t.verbose = true
  end

  desc("Run functionals test and validate generated HTML with Tidy")
  task :'html:validation' do
    ENV["VALIDATE_HTML"] = "true"
    Rake::Task["test:functional"].invoke
  end
  
  task :integration_smoke do
    ENV["run_as_dev"] = "true"
    Rake::Task["test:run_smoke"].invoke
  end
  
  task :selenium_smoke do 
    Rake::Task[:'test:selenium:start'].invoke
    Rake::Task[:'test:selenium:restart_application'].invoke
    Rake::Task["test:run_smoke"].invoke
    Rake::Task[:'test:selenium:stop_application'].invoke
    Rake::Task[:'test:selenium:stop'].invoke
  end

end

task :enable_all_stubs do
  require File.join(File.dirname(__FILE__), "/../../test/stubs/enable_all_stubs.rb")
end

# $LOAD_PATH << File.expand_path(File.dirname(__FILE__) + "/../../vendor/gems/deep_test-1.0.2/lib")
require "rubygems"
require "deep_test/rake_tasks"

DeepTest::TestTask.new "deep_test:functional" do |t|
  t.pattern = "test/functional/**/*_test.rb"
  t.number_of_workers = 2   # optional, defaults to 2
  t.timeout_in_seconds = 30 # optional, defaults to 30
  t.server_port = 6969      # optional, defaults to 6969
end