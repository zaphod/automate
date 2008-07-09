# $LOAD_PATH << File.expand_path(File.dirname(__FILE__) + "/../../vendor/gems/deep_test-1.0.2/lib")
require 'rubygems'
require 'deep_test'
require "deep_test/rake_tasks"

DeepTest::TestTask.new "deep_test:functional" do |t|
  t.pattern = "test/suites/functional/**/*_test.rb"
  t.processes = 2
end
