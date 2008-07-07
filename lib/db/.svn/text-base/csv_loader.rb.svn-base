require 'yaml'
require 'erb'
require 'benchmark'

class CsvLoader
  
  NEWLINE = '\n'

  class << self
    def load(from_csv_path)
      puts "Loading database of RAILS_ENV=#{RAILS_ENV} with #{File.expand_path(from_csv_path)}/*.csv:\n\n"

      connection.execute "SET FOREIGN_KEY_CHECKS=0;"
      Dir["#{from_csv_path}/**/*.csv"].each do |file|
  	    filename =  File.basename(file)
  	    table_name = filename.split('.').first.tableize
        Timer.benchmark(table_name) { populate_table(File.join(from_csv_path, filename), table_name) }
      end
      connection.execute "SET FOREIGN_KEY_CHECKS=1;"
    end
  
    def dump(to_csv_path)
      puts "Dumping database state of RAILS_ENV=#{RAILS_ENV} to #{File.expand_path(to_csv_path)}"
      
      table_to_type = {}
      Dir["#{to_csv_path}/*"].collect { |file| File.basename(file) }.each { |data_type| 
        Dir["#{to_csv_path}/#{data_type}/*.csv"].each { |file| 
            table_name = File.basename(file).split(".").first
            table_to_type[table_name] = data_type
          }
      }
            
      connection.tables.collect { |table| table.classify.pluralize if table !~ /(schema_info|squish_vin|image_queue)/ }.compact.each do |table|
        # Have to insert header line after dumping CSV content instead of SQL UNION because 
        # otherwise all content will be all implicitly dumped as string quoted due to first 
        # UNION trumps data types.
        unless connection.select_one("SELECT COUNT(*) FROM #{table.tableize};").values.first.to_i == 0
          path = table_to_type[table].nil? ? "#{to_csv_path}" : "#{to_csv_path}/" + table_to_type[table]
          create_csv_file(path, table) 
          insert_headers_into(File.join(path, "#{table}.csv"), table)
        end
      end
    end
  
    private
    
    def connection
      @connection ||= ActiveRecord::Base.connection
    end
    
    def populate_table(file, table_name)      
      connection.execute "TRUNCATE table #{table_name};"
      load_file_sql = %Q[LOAD DATA INFILE '#{connection.quote_string(file)}' INTO TABLE #{table_name} FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '\\"' LINES TERMINATED BY '#{NEWLINE}' IGNORE 1 LINES;]
      connection.execute load_file_sql

      csv_content = File.open(file, 'rb').read
      expected = csv_content.split("\n").size - 1 # 1 header line
      actual = connection.select_one("SELECT COUNT(*) FROM #{table_name};").values.first.to_i
      raise "SQL: #{load_file_sql}\nLost data while loading #{table_name}: Expected: #{expected}, Actual: #{actual}" if expected != -1 and actual != expected
    end
  	
  	def create_csv_file(to_csv_path, table)
      target_path = File.expand_path(to_csv_path)
      chmod 0777, target_path, :verbose => false
      file = File.join(target_path, "#{table}.csv")
      rm file if File.exists? file
      dump_file_sql = %Q[SELECT * INTO OUTFILE '#{connection.quote_string(file)}' FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '\\"' LINES TERMINATED BY '#{NEWLINE}' FROM #{table.tableize};]      
      connection.execute dump_file_sql
    end

    def insert_headers_into(csv_file, table)
      header_line = retrieve_headers_for(table).collect { |column_name| %Q{"#{column_name}"} }.join(", ")
      file_content = File.new(csv_file, 'r').read
      File.open(csv_file, 'w+') do |file|
        file << "#{header_line}\n" << file_content
      end
    end

    def retrieve_headers_for(table)
      column_names = []    
      connection.execute("SHOW FIELDS FROM #{table.tableize};").each do |row|
        column_names << row.first
      end
      column_names
    end
  end
  
  class Timer
    def self.benchmark(text, &block)
      if ENV['QUIET']=="true"
        yield
        return
      end
  		print "%20s " % text
  		puts "%s" % [Benchmark.measure(&block)]
  	end
  end
  
end

