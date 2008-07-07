require File.dirname(__FILE__) + '/../db/csv_loader'
require 'csv'

namespace :qa do

  task :foo => [:environment] do
    `mysql -u root -e "DROP DATABASE chu_development; CREATE DATABASE chu_development;"`
    Rake::Task[:'db:migrate'].invoke
    
    Dir[File.expand_path("#{RAILS_ROOT}/test/fixtures/selenium/baseline")].each do |path|
      ENV['FROM'] = ENV['TO'] = path      
      Rake::Task[:'qa:yaml_to_db'].invoke
      Rake::Task[:'qa:dump_csv'].invoke
      FileUtils.rm Dir.glob(File.join(path, "*.yml"))
      puts "Now run: rake qa:load_database FROM=#{path}"
    end
  end
  
  
  desc "Convert all files in {FROM}/*.yml to {TO}"
  task :yaml_to_db => [:environment] do
    yaml_path = File.expand_path(ENV['FROM'])
    
    puts "Converting files in '#{yaml_path}/*.yml' to RAILS_ENV=#{RAILS_ENV}"
    Dir[File.join(yaml_path, '/**/*.yml')].each do |path_to_file|
      File.open(path_to_file) do |file|
        table_name = File.basename(path_to_file).split('.').first
        data = YAML.load(file.read)
        
        klass_name = table_name.singularize.camelize
        self.class.class_eval %Q{ 
          class #{klass_name} < ActiveRecord::Base
          end
        }
        
        klass = eval("#{klass_name}")
        data.each_pair do |key, value|
          klass.create(value)
        end
        
	if table_name != "time_zone_infos"
	  raise "Convertion contains error: Expected yaml count = #{data.values.size}, Actual db records inserted = #{klass.count}..." if klass.count != data.values.size
	end
      end
    end

  end

  desc "Load {FROM}/*.csv into RAILS_ENV database"
  task :load_database => [:environment] do
    raise 'Argument FROM= required.' unless ENV['FROM']
    CsvLoader.load ENV['FROM']
  end

  desc "Dump RAILS_ENV database data into {TO} as *.csv files"
  task :dump_csv => [:environment] do
    raise 'Argument TO= required.' unless ENV['TO']
    CsvLoader.dump ENV['TO']
  end

end