desc      "Cleans tmp/ and log/ folders."
task      :clean_all => [:'clean_all:default']
namespace :clean_all do
  
  task :default => [:tmp, :log]
  
  private
  
  task :tmp => [:'tmp:clear']
  
  task :log => [:'log:clear']
  
end