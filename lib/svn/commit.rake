require 'readline'

Rake::Task[:default].prerequisites.clear
Rake::Task[:default].enhance [:pc]

task :pc => %w[
  log:clear
  svn:delete
  svn:up
  svn:fail_on_conflict
  translations:generate_dev
  translations:generate_fr
  db:reset_if_necessary
  test:unit
  db:test:prepare
  deep_test:functional
  svn:add
  growl:update_cruise
  svn:st
  show_success
]

task :show_success do
  puts "about to check in"
end

task :update_message do
  update_all_saved_data
end

task :abort_on_broken_build do
  `curl -s http://cruise_url:port/ | grep "project_name" | grep "project build_success"`
  
  unless $?.success?
    puts "Uh oh, the build is broken!"
    choice = Readline.readline("CI Build is currently broken.  Are you sure you want to commit? (y/n): ")
    raise "Cancelling commit due to broken build." unless choice == 'y'
  end
end

desc "Run to check in"
task :commit => ['svn:st', :update_message, 'svn:delete', 'svn:up', 'svn:fail_on_conflict', :pc, :abort_on_broken_build, 'svn:merge_to_trunk', :recognize] do
  username = get_saved_data "username"
  commit_pair = get_saved_data "pair"
  story_or_bug_number = get_saved_data "story_name_or_bug_number"
  commit_message = get_saved_data "message"
  
  command = %[svn ci --username #{username.chomp} -m "#{commit_pair.chomp}: #{story_or_bug_number.chomp} - #{commit_message.chomp}"]
  puts command
  puts %x[#{command}]
end

desc "To be run by ba's to check in data"
task :commit_data => ['svn:up', 'svn:fail_on_conflict', 'db:reset'] do
  update_saved_data "username"
  update_saved_data "message"
  username = get_saved_data "username"
  message = get_saved_data "message"

  command = %[svn ci --username #{username.chomp} -m "#{username.chomp}: data - #{message.chomp}"]
  puts command
  puts %x[#{command}]
end

desc 'merge changes from branch to trunk'
task :'svn:merge_to_trunk' do
  if %x[svn info].include? "branches" 
    puts "Merging changes into trunk.  Don't forget to check these in." 
    trunk = "#{RAILS_ROOT}/../trunk"
    system "svn up #{trunk}; svn diff | patch -p0 -d #{trunk}" 
  end
end

task :ci => :commit

DEVS = %w[
          list
          of 
          devs
         ]

task :recognize do
  if get_saved_data("story_complete").downcase.include?("y")
    require 'playlist'
    ENV['playlist_host'] = "{:machine => 'machine.name.local', :username => '', :password => ''}"
    Playlist.play(developers)
  end
end

task :standup do
  require 'playlist'
  ENV['playlist_host'] = "{:machine => 'machine.name.local', :username => '', :password => ''}"
  Playlist.play ["standup"]
end

task :birthday do
  require 'playlist'
  ENV['playlist_host'] = "{:machine => 'machine.name.local', :username => '', :password => ''}"
  Playlist.play ["birthday"]
end

task :benny do
  require 'playlist'
  ENV['playlist_host'] = "{:machine => 'machine.name', :username => '', :password => ''}"
  Playlist.play ["benny"]
end

def developers
  pair = get_saved_data "pair"
  pair.downcase.gsub("/", " ").split(" ").select { |p| DEVS.include? p }
end

def get_saved_data attribute
  data_path = File.expand_path(File.dirname(__FILE__) + "/#{attribute}.data")
  File.read(data_path)
end

def update_saved_data attribute
  
  data_path = File.expand_path(File.dirname(__FILE__) + "/#{attribute}.data")
  `touch #{data_path}` unless File.exist? data_path
  saved_data = File.read(data_path)
  
  puts "last #{attribute}: " + saved_data unless saved_data.chomp.empty?
  input = nil
  loop do 
    input = Readline.readline("#{attribute}: ")
    break unless (saved_data.chomp.empty? && input.chomp.empty?)
  end

  if input.chomp.any?
    File.open(data_path, "w") { |file| file << input }
  else
    puts "using: " + saved_data.chomp
  end
  input.chomp.any? ? input : saved_data
end

def update_all_saved_data
  attributes = {}
  ["username", "pair", "story_name_or_bug_number", "message", "story_complete"].each do |attribute|
    data_path = File.expand_path(File.dirname(__FILE__) + "/#{attribute}.data")
    `touch #{data_path}` unless File.exist? data_path
    saved_data = File.read(data_path)
    attributes[attribute] = saved_data
    puts "last #{attribute}: " + saved_data
  end
  
  if attributes.values.any? { |element| element.empty? }
    ["username", "pair", "story_name_or_bug_number", "message", "story_complete"].each do |attribute|
      update_saved_data attribute
    end
    return
  end

  input = 'N'
  
  input_thread = Thread.new { input = Readline.readline("updates? [y|m|N] ") }
  reaper_thread = Thread.new do
    endtime = Time.now + 3
    loop do
      break if !input_thread.status
      break if Time.now >= endtime
    end
    puts "N" if Time.now >= endtime
    input_thread.terminate
  end
  input_thread.join
  reaper_thread.join

  if input == 'y'
    ["username", "pair", "story_name_or_bug_number", "message", "story_complete"].each do |attribute|
      update_saved_data attribute
    end
  elsif input == "m"
    update_saved_data "message"
  end

end

def say statement, voice = "Bruce"
  if RUBY_PLATFORM =~ /darwin/
    `echo  | sudo -S -p '' ls`
    old_volume = `osascript -e "get Volume settings" | sed 's/,.*$//' | sed 's/^.*://'`.strip
    old_volume = old_volume.to_i/10
    %x[osascript -e "set Volume 100"]
    puts statement
    %x[say -v "#{voice}" "#{statement}"]
    %x[osascript -e "set Volume #{old_volume}"]
  end
end


