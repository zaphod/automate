desc "Start BackgrounDRb Workers"

task :backgroundrb => [:environment] do
  raise "Usage rake backgroundrb action=start/stop" unless ENV['action']
  action = ENV['action']
  system "ruby #{RAILS_ROOT}/script/backgroundrb #{action}"
  sleep 5 # need to wait till the backgroundrb starts
  Rake::Task["start_backgroundrb_workers"].invoke if action == "start"
end

task :start_backgroundrb_workers => [:environment] do
  workers = Dir.glob("#{RAILS_ROOT}/lib/workers/*_worker.rb").map { |file| File.basename(file,".rb") }
  workers.each do |worker|
    job_key = worker.to_s
    raise "job_key cannot be longer than 20 characters" if job_key.size > 20
    puts "Starting #{worker} background worker...."
    MiddleMan.new_worker :class => worker.to_sym, :job_key => job_key.to_sym
  end
end

task :start_single_backgroundrb_worker => [:environment] do
  puts "Starting #{ENV['WORKER']} background worker...."
  MiddleMan.new_worker :class => ENV['WORKER'].to_sym, :job_key => :aaa
end
