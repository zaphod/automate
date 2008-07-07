require 'rake'

require File.dirname(__FILE__) + "/../../db/my_sql/database"
require File.dirname(__FILE__) + "/../../db/my_sql/database_configuration"
require File.dirname(__FILE__) + "/../../db/dataset"

namespace :db do
  
  namespace :data do
    DB::Dataset.each do |dataset|
      desc "reset.rake: Use the #{dataset.name} dataset" 
      task dataset.name do
        DB::Dataset.select dataset.name
      end    
    end
  end

end
