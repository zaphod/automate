
functional_spec_areas = ["List", "Of", "Folders", "containing", "tests/specs"]

functional_directory        = '../dash/functional'
public_dashboard_directory  = '../dash/public/results'
revision = ''
%x[svn info].split(/\n/).each do |line|
  revision = line.split(':')[1].strip if (line.include?('Revision'))
end

begin
  require 'spec/rake/spectask'
  
  #Run all Selenium specs, Results will collect into one log, and one html file
  Spec::Rake::SpecTask.new("qa:all") do |t| 
    t.spec_files = FileList['test/qa/ruby_selenium/**/spec_*.rb']
    t.spec_opts = [
      '--color', '--diff',
      '--require', 'rubygems,spec/ui', 
      '--format', "s:#{functional_directory}/logs/spec_results_#{revision}.log",
      '--format', "Spec::Ui::ScreenshotFormatter:#{public_dashboard_directory}/spec_all_results_#{revision}.html",
      '--format', 'progress'
    ]
    t.fail_on_error = false    
  end

  #Run Selenium smoke specs
  Spec::Rake::SpecTask.new("qa:acc:smoke") do |t| 
    t.spec_files = FileList['test/ruby_selenium/smoke/smoke_*.rb']
    t.spec_opts = ['-f', 'h:smoke_spec_results.html']
  end

  #Run all Selenium specs, Results will collect into one log and one html file per functional_spec_area
  functional_spec_areas.each do |area|
    Spec::Rake::SpecTask.new("qa:#{area}") do |t|
      t.spec_files = FileList["test/qa/ruby_selenium/**/spec_#{area}*.rb"]
      t.spec_opts = [
         '--color', '--diff',
         '--require', 'rubygems,spec/ui', 
         '--format', "s:#{functional_directory}/logs/spec_#{area}_results_#{revision}.log",
         '--format', "Spec::Ui::ScreenshotFormatter:#{public_dashboard_directory}/#{area}/build#{revision}/spec_#{area}_results_#{revision}.html",
         '--format', 'progress'
       ]
      t.fail_on_error = false    
    end
  end

  desc "Start selenium server"
  task :selenium_server  do
    `cd /bin && selenium`
  end

  desc "Start selenium server in multiWindow mode: This opens a separate window with no frames"
  task :selenium_server_multi  do
    `cd /bin && selenium -multiWindow`
  end

  desc "Reload/Migrate the db, run the selenium tests, and report results to the dashboard"
  task :run_selenium_specs => [:'db:data:sample_data', :'db:dev:reset', :'qa:#{area}']

rescue LoadError
  # don't complain if we don't have rspec, just don't define the task.
end


