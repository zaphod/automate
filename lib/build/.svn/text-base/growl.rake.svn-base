namespace :growl do
  task :update_cruise do
    config_location = File.join(RAILS_ROOT,'cruise_config.rb')
    begin
      host = `hostname`.chomp
      `ifconfig` =~ /inet (10\.\d+\.\d+\.\d+)/
      ip = $1
      return unless ip
      cruise_config = File.readlines(config_location)

      unless cruise_config.any? { |line| line =~ /"#{ip}", # #{host}/ }  
        new_cruise_config = []
        new_cruise_config << cruise_config.shift until cruise_config.first =~ /## BEGIN AUTO GROWL/
        new_cruise_config << cruise_config.shift
      
        until cruise_config.first =~ /## END AUTO GROWL/
          line = cruise_config.shift
          new_cruise_config << line unless line =~ /#{ip}/ or line =~ /#{host}/
        end
        
        new_cruise_config << "      \"#{ip}\", # #{host}\n"
      
        new_cruise_config << cruise_config.shift while cruise_config.first
        
        File.open(config_location, 'w') do |io|
          io << new_cruise_config.join
        end
      end
    rescue
      # don't do anything for now, assume we're on the wrong platform
    end
  end
end