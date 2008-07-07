Rake::Task[:test].prerequisites.clear
Rake::Task[:test].enhance %w[test:unit deep_test:functional]

Rake::TestTask.new("test:unit" => [:environment]) do |t|
  t.test_files = FileList['test/suites/unit/**/*_test.rb']
end
Rake::Task["test:unit"].comment = "run unit tests"

Rake::TestTask.new("test:functional" => [:environment, :'db:test:prepare', :insert_factory_defaults]) do |t|
  t.test_files = FileList['test/suites/functional/**/*_test.rb']
end
Rake::Task["test:functional"].comment = "run functional tests"

Rake::TestTask.new("test:externals" => [:environment, :'db:test:prepare', :insert_factory_defaults]) do |t|
  t.pattern = 'test/suites/externals/**/*_test.rb'
end
Rake::Task["test:externals"].comment = "run externals tests"

Rake::Task["test:units"].prerequisites.clear
Rake::Task["test:units"].instance_variable_get("@actions").clear
Rake::Task["test:units"].enhance ["test:unit"]

Rake::Task["test:functionals"].prerequisites.clear
Rake::Task["test:functionals"].instance_variable_get("@actions").clear
Rake::Task["test:functionals"].enhance ["test:functional"]
