class Automate
  
  def self.run
    unless($*.empty?)
      project = "#{Dir.pwd}/#{$*}"
      puts "Automating project #{project}"
      tasks = "#{project}/lib/tasks"
      puts "Copying rake tasks to #{tasks}"
      gemdir = File.expand_path(File.dirname(__FILE__))
      command = "cp -R #{gemdir}/* '#{tasks}'"
      system command
    else
      usage
    end
  end
  
  def self.usage
    puts "Usage : automate <project_name>"
  end
  
end