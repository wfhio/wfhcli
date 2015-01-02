require 'test/unit'
require 'wfhcli'

class TestWfhLib < Test::Unit::TestCase
  def setup
    @wfh = WfhLib.new
  end

  def test_format_date
    date = '2014-09-17T20:45:30.000Z'
    assert_equal @wfh.format_date(date), '2014-09-17'
  end

  def test_format_date_with_time
    date = '2014-09-17T20:45:30.000Z'
    assert_equal @wfh.format_date(date, inc_time=true), '2014-09-17 20:45'
  end

  def test_generate_table
    content = [['ID', 'Name'], [1, 'Test']]
    actual_output = @wfh.generate_table(content)
    expected_output = "| \e[35mID\e[0m | \e[35mName\e[0m |\n|----|------|\n| 1  | Test |\n"
    assert_equal actual_output, expected_output
  end

  def test_generate_header_and_body
    actual_output = @wfh.generate_header_and_body('Test', 'test')
    expected_output = "\e[35mTest\e[0m\ntest"
    assert_equal actual_output, expected_output
  end

  def test_truncate
    str = 'This is a test string which we will truncate'
    assert_equal @wfh.truncate(str, 10), 'This is...'
  end
end
