require 'test/unit'
require 'wfhcli'

class TestWfhCli < Test::Unit::TestCase
  def test_format_date
    date = '2014-09-17T20:45:30.000Z'
    assert_equal format_date(date), '2014-09-17'
  end

  def test_generate_table
    content = [['ID', 'Name'], [1, 'Test']]
    actual_output = generate_table(content)
    expected_output = "| ID | Name |\n|----|------|\n| 1  | Test |\n"
    assert_equal actual_output, expected_output
  end

  def test_truncate
    str = 'This is a test string which we will truncate'
    assert_equal truncate(str, 10), 'This is...'
  end
end
