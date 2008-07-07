namespace :db do

  namespace :test do
    
    desc "Drop test database"
    task :drop => :environment do
      abcs = ActiveRecord::Base.configurations
      case abcs["test"]["adapter"]
        when "mysql"
          ActiveRecord::Base.establish_connection(:test)
          ActiveRecord::Base.connection.recreate_database(abcs["test"]["database"])
      end
    end
  end  
end
