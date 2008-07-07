desc('Start multiple processes to download the parking lot images.')
task :'parking_lot_image_downloader:start' => [:environment, :'parking_lot_image_downloader:clear_pid_files'] do
  PARKING_LOT_IMAGE_DOWNLOADER_COUNT.times do |process_number|
    cmd = %{
      nohup
        #{RAILS_ROOT}/script/parking_lot_image_download_script.rb
        -p #{RAILS_ROOT}/tmp/pids/parking_lot_image_downloader.#{process_number}.pid
        &
    }.gsub("\n", " ")
           
    puts "Launching '#{cmd}'"
    system cmd
    raise "Could not start '#{cmd}'" unless $? == 0
  end
  
end

desc('Stop all parking lot image downloaders.')
task :'parking_lot_image_downloader:stop' => :environment do
  pids = `cat #{RAILS_ROOT}/tmp/pids/parking_lot_image_downloader.*.pid`.gsub /\n/, ' '
  sh "kill #{pids}" unless pids.blank?
  Rake::Task[:'parking_lot_image_downloader:clear_pid_files'].invoke
end

task :'parking_lot_image_downloader:clear_pid_files' => :environment do
  sh "rm -f #{RAILS_ROOT}/tmp/pids/parking_lot_image_downloader.*.pid"
end
