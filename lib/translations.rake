namespace :translations do

  desc "Generate fr.yml"
  task :generate_fr => [:environment] do
    require "find"

    Find.find("#{RAILS_ROOT}/lang") do |path|
      if File.basename(path) == "en.yml"
        en = YAML.load(File.read(path))
        fr_yml = File.join(File.dirname(path), "fr.yml")
        fr = File.open(fr_yml, "w") do |io|
          en.each { |key, value| io.puts "#{key}: \"l'#{value.to_s.gsub(/["']/, '')}\"" }
        end
      end
    end
  end
  
  desc "Generate dev.yml"
  task :generate_dev => [:environment] do
    require "find"

    Find.find("#{RAILS_ROOT}/lang") do |path|
      if File.basename(path) == "en.yml"
        en = YAML.load(File.read(path))
        dev_yml = File.join(File.dirname(path), "dev.yml")
        File.delete(dev_yml) if File.exists?(dev_yml)
        dev = File.open(dev_yml, "w") do |io|
          en.each { |key, value| io << "#{key}: #{key}\n" }
        end
      end
    end
  end

end
