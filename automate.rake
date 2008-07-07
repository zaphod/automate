#http://www.linuxjournal.com/article/8967
require 'rubygems'
Gem::manage_gems
require 'rake/gempackagetask'

spec = Gem::Specification.new do |s|
    s.platform  =   Gem::Platform::RUBY
    s.name      =   "automate"
    s.version   =   "0.1"
    s.author    =   "Sudhindra Rao"
    s.email     =   "srrao2k @@ gmail.com"
    s.homepage  =   "http://www.sudhindrarao.com"
    s.summary   =   "A set of tools to automate your rails project."
    
    s.files     =   FileList['lib/**/*.*', 'bin/**/*.*'].to_a
    s.require_path  =   "lib"
    s.bindir    = "bin"

    s.executables << 'automate'
    s.autorequire   =   "automate"
    s.test_files = Dir.glob('tests/*.rb')
    s.has_rdoc  =   true
    # s.extra_rdoc_files = ["README"]
    
    s.add_dependency("unit_record")
    s.add_dependency("ZenTest")
    s.add_dependency("dust")
    s.add_dependency("deep_test")
end

Rake::GemPackageTask.new(spec) do |pkg|
    pkg.need_tar = true
end

task :default => "pkg/#{spec.name}-#{spec.version}.gem" do
    puts "generated latest version"
end