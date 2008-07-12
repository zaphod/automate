require "test/unit"
require "automate"
 

class AutomateTest < Test::Unit::TestCase

  def test_should_call_usage
    assert (Automate.usage.include?("Usage :"))
  end
  
  def test_run
    Automate.run
  end
  
  def test_mkdir
    assert_equal("project/lib/tasks/automate", Automate.mkdir("project"))
  end
  
  def test_copy_rake_tasks
    assert_equal("project/lib/tasks/automate", Automate.copy_rake_tasks("project/lib/tasks/automate"))
  end

end