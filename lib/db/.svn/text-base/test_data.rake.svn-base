require 'benchmark'

namespace :db do
  include FileUtils
  
	desc "Populate test data into the database."
	task :populate_test_data => [:environment, :'db:migrate', :enable_all_stubs] do
	  require 'db/dataset'
	  dataset = DB::Dataset.selected
	  total = Benchmark.measure {dataset.load}
  	puts "\n== Dataset #{dataset.name}: #{total}"
	end

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
	
	private
	
	def benchmark(text, &block)
		print "#{INDENTATION} " % text
		puts "%s" % [Benchmark.measure(&block)]
	end
	  
end
