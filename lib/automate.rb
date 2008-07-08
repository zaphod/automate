class Automate
  
  def self.run
    unless($*.empty?)
      project = "#{Dir.pwd}/#{$*}"
      target = mkdir(project)
      target = copy_rake_tasks(target)
    else
      usage
    end
  end
  
  def self.usage
    puts "Usage : automate <project_name>"
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