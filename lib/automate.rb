class Automate
  
  def self.run
    unless($*.empty?)
      args = $*
      project_name = args[0]
      project = "#{Dir.pwd}/#{args[0]}"
      target = mkdir(project)
      target = copy_rake_tasks(target)
    else
      puts usage
    end
  end
  
  def self.usage
    "Usage : automate <project_name>"
  end
  
  def self.mkdir(project)
    puts "Automating project #{project}"
    target = "#{project}/lib/tasks/automate"
    puts "Making directory #{target}"
    command = "mkdir '#{target}'"
    system command
    target    
  end

  def self.copy_rake_tasks(target)
    puts "Copying rake tasks to #{target}"
    gemdir = File.expand_path(File.dirname(__FILE__))
    command = "cp -R #{gemdir}/* '#{target}'"
    system command
    target    
  end
end