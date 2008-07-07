begin
  sitearch = RUBY_PLATFORM
  
  rcov_path = File.expand_path("#{RAILS_ROOT}/vendor/gems/rcov-0.8.0.2")
  rcov_lib = rcov_path + '/lib'
  rcov_bundle_path = "#{rcov_path}/ext/rcovrt/#{sitearch}"
  rcov_output = ENV["CC_BUILD_ARTIFACTS"] || 'tmp/coverage'

  require "#{rcov_lib}/rcov/rcovtask"
  require 'rbconfig'
  include Config
  
  ENV['RCOVPATH'] = rcov_path + '/bin/rcov'

  CLOBBER.include("coverage")

  desc "Generate a coverage report for unit and functional tests"
  Rcov::RcovTask.new(:coverage => [:environment, 'db:test:prepare', 'db:migrate']) do |t|
      t.test_files = FileList['test/unit/**/*_test.rb'] + FileList['test/functional/**/*_test.rb']
      t.rcov_opts = ['--html', '--rails']
      t.libs << '"' + rcov_lib + '"'
      t.libs << '"' + rcov_bundle_path + '"'
      t.output_dir = rcov_output
  end
  
  namespace :coverage do
    
    Rcov::RcovTask.new(:unit => [:environment]) do |t|
      t.test_files = FileList['test/unit/**/*_test.rb']
      t.rcov_opts = ["--html", "--rails", "--include-file 'app/models/body_type.rb'", "--exclude 'app/helpers,app/controllers,/usr/local/lib/site_ruby/1.8/rbconfig,/usr/local/lib/site_ruby/1.8,/usr/local/lib/site_ruby/1.8/rubygems'"]
      t.libs << '"' + rcov_lib + '"'
      t.libs << '"' + rcov_bundle_path + '"'
      t.output_dir = rcov_output + '/unit'
    end

    Rcov::RcovTask.new(:functional => [:environment, 'db:test:prepare', 'db:migrate']) do |t|
      t.test_files = FileList['test/functional/**/*_test.rb']
      t.rcov_opts = ['--html', '--rails', "--exclude '/usr/local/lib/site_ruby/1.8/rbconfig,/usr/local/lib/site_ruby/1.8,/usr/local/lib/site_ruby/1.8/rubygems'"]
      t.libs << '"' + rcov_lib + '"'
      t.libs << '"' + rcov_bundle_path + '"'
      t.output_dir = rcov_output + '/functional'
    end

    desc "Delete aggregate coverage data."
    task(:clean) { rm_f "rcov_tmp" }
    
    Rcov::RcovTask.new(:unit_for_combined_report => [:clean, :environment]) do |t|
      t.test_files = FileList['test/unit/**/*_test.rb']
      t.rcov_opts = ["--aggregate 'rcov_tmp'", "--html", "--rails", "--include-file 'app/models/body_type.rb'", "--exclude 'db,/usr/local/lib/site_ruby/1.8/rbconfig,/usr/local/lib/site_ruby/1.8,/usr/local/lib/site_ruby/1.8/rubygems'"]
      t.libs << '"' + rcov_lib + '"'
      t.libs << '"' + rcov_bundle_path + '"'
      t.output_dir = rcov_output + '/unit_combined'
    end
    
    desc "Generate combined unit and functional test coverage report"
    Rcov::RcovTask.new(:unit_and_functional => [:environment, :unit_for_combined_report, 'db:test:prepare', 'db:migrate']) do |t|
      t.test_files = FileList['test/functional/**/*_test.rb']
      t.rcov_opts = ["--aggregate 'rcov_tmp'", '--html', '--rails', "--exclude 'db,/usr/local/lib/site_ruby/1.8/rbconfig,/usr/local/lib/site_ruby/1.8,/usr/local/lib/site_ruby/1.8/rubygems'"]
      t.libs << '"' + rcov_lib + '"'
      t.libs << '"' + rcov_bundle_path + '"'
      t.output_dir = rcov_output + '/unit_and_functional'
    end

    Rcov::RcovTask.new(:run_smoke => [:environment, 'db:test:load']) do |t|
      t.test_files = FileList['test/ruby_selenium/smoke/**/smoke_*.rb']
      t.rcov_opts = ['--html', '--rails']
      t.libs << '"' + rcov_lib + '"'
      t.libs << '"' + rcov_bundle_path + '"'
      t.output_dir = rcov_output +'/integration_smoke'
    end
    
    task :integration_smoke do
      ENV["run_as_dev"] = "true"
      Rake::Task["coverage:run_smoke"].invoke
    end

  end
rescue Exception
  puts "WARNING: Unable to load RCov"
end
