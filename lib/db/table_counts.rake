namespace :db do
  
  desc "SELECT COUNT(1) on all tables"
  task :table_counts => :environment do
    include ActionView::Helpers::NumberHelper
    ActiveRecord::Base.connection.tables.sort.each { |table| puts "%40s: %s" % [table.ljust(35, '.'), number_with_delimiter(ActiveRecord::Base.connection.select_one('SELECT COUNT(1) FROM ' + table).values.first).rjust(10, ' ')] }
  end
end