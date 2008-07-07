module Selenium

  class RemoteControl

    PORT = 4444
    HOST = "localhost"
  
    def self.start
      sh "selenium > log/selenium.output 2>log/selenium.output &"
      start_time = Time.now
      selenium_pid = ""
      print "Waiting for Selenium RC"
      while selenium_pid.empty? and (Time.now - start_time) < 30
        puts "."
        sleep 1
        selenium_pid = `lsof -t -i :#{PORT}`
      end
      raise "Could not start selenium server" if selenium_pid.empty?
    end

    def self.stop
      sh "curl -S -s http://#{HOST}:#{PORT}/selenium-server/driver/?cmd=shutDown"
    end
    
    def self.restart
      begin
        stop
      rescue => e
        puts "Ignoring problem while attempting to shut down Selenium server : #{e}"
      end
      start
    end
  
  end

  class Application
  
    def self.start
      port = ENV['SELENIUM_APPLICATION_PORT']
      port_override = port ? "-p #{port}" : ""
      db_schema_override = ENV['DB_SCHEMA_BASE'] ? %Q{DB_SCHEMA_BASE="#{ENV['DB_SCHEMA_BASE']}"} : ""
      sh "#{db_schema_override} mongrel_rails start -d #{port_override} -P log/mongrel.pid"
    end

    def self.stop
      sh "mongrel_rails stop -P log/mongrel.pid"
      sh "rm -f log/mongrel.pid"
    end

    def self.restart
      begin
        stop
      rescue => e
        puts "Ignoring problem while attempting to shut down application : #{e}"
      end
      start
    end
  
  end

end