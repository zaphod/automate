namespace :test do
  namespace :selenium_grid do
    desc("Start selenium remote control locally")
    task :start_remote_control do 
      Selenium::RemoteControl.restart
    end    

    desc("Upload DB sql dump to the machine hosting Selenium Grid farm database")
    task :upload_sqldump => :environment do 
      sh "scp #{RAILS_ROOT}/tmp/#{RAILS_ENV}.mysqldump login@#{ENV['SELENIUM_APPLICATION_HOST']}:/tmp"      
    end

    desc("Update code and database for all Mongrels serving the selenium farm")
    task :update_servers => :environment do
      sh "cap -f #{RAILS_ROOT}/config/selenium_grid_deploy.rb #{ENV['APP_CAP_ENVIRONMENT']} update_cluster"
    end
  end
end
