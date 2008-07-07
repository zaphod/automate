desc "CI task"
task :build => %w[
  environment
  tmp:clear
  log:clear
  db:reset
  test:unit
  test:functional
  performance:metrics:harvest
]

task :'build:externals' => [:environment, :clean_all,  :'db:reset', :'test:externals' ]

task :'build:html:validation' => [:environment, :clean_all, :'db:reset', :'test:html:validation' ]

task :'build:datasets' do
  DB::Dataset.each do |dataset|
    sh "rake DATASET='#{dataset.name}' db:reset"
  end
end

task :'build:migrations' do
  sh "rake db:migrate"
  sh "rake db:migrate VERSION=1"
  sh "rake db:migrate"
end

desc("Launch Firefox view build")
task :'build:view:firefox' => [:environment, :'test:view:environment', :'tmp:clear', :'db:data:sample_data', :'db:reset', :'test:view:update_servers', :'test:view:upload_sqldump' ] do
  Rake::Task[:'test:view:firefox'].invoke
end

desc("Launch IE view build")
task :'build:view:ie' => [:environment, :clean_all, :'db:data:sample_data', :'db:reset'] do
  Rake::Task[:'test:view:ie'].invoke
end



