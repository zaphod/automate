namespace :services do
  
  desc 'Stub all external services.'
  task :stub_all do
    require File.join(File.dirname(__FILE__), "/../../test/infrastructure/stubs/enable_all_stubs.rb")
  end

end
