require 'test/unit'
require 'webmock/test_unit'
require 'wfhcli'

class TestWfhLib < Test::Unit::TestCase
  def setup
    @wfh = WfhLib.new
    @headers = { 'Accept' => 'application/json', 'Accept-Encoding' => 'gzip, deflate', 'User-Agent' => 'wfhcli' }
  end

  def test_format_date
    date = '2014-09-17T20:45:30.000Z'
    assert_equal @wfh.format_date(date), '2014-09-17'
  end

  def test_format_date_with_time
    date = '2014-09-17T20:45:30.000Z'
    assert_equal @wfh.format_date(date, true), '2014-09-17 20:45'
  end

  def test_generate_table
    content = [%w{ID Name}, [1, 'Test']]
    actual_output = @wfh.generate_table(content)
    expected_output = "| \e[35mID\e[0m | \e[35mName\e[0m |\n|----|------|\n| 1  | Test |\n"
    assert_equal actual_output, expected_output
  end

  def test_generate_header_and_body
    actual_output = @wfh.generate_header_and_body('Test', 'test')
    expected_output = "\e[35mTest\e[0m\ntest\n"
    assert_equal actual_output, expected_output
  end

  def test_truncate
    str = 'This is a test string which we will truncate'
    assert_equal @wfh.truncate(str, 10), 'This is...'
  end

  def test_display_categories
    response = [
      { 'id' => 1, 'name' => 'Test category' },
      { 'id' => 2, 'name' => 'Test category 2' }
    ]
    stub_request(:get, "#{@wfh.url}/categories").
      with(headers: @headers).
        to_return(status: 200, body: JSON.dump(response), headers: {})
    output = "| \e[35mID\e[0m | \e[35mName           \e[0m |\n"
    output << "|----|-----------------|\n"
    output << "| 1  | Test category   |\n"
    output << "| 2  | Test category 2 |\n"
    assert_equal @wfh.display_categories, output
  end

  def test_display_company
    response = {
      'id' => 1,
      'name' => 'Test company',
      'url' => 'http://www.test.com',
      'twitter' => 'test_company',
      'showcase_url' => ''
    }
    stub_request(:get, "#{@wfh.url}/companies/1").
      with(headers: @headers).
        to_return(status: 200, body: JSON.dump(response), headers: {})
    output = "\e[35mName\e[0m\nTest company\n"
    output << "\e[35mURL\e[0m\nhttp://www.test.com\n"
    output << "\e[35mTwitter\e[0m\ntest_company\n"

    assert_equal @wfh.display_company(1), output
  end

  def test_display_companies
    response = [
      { 'id' => 1, 'name' => 'Test company' },
      { 'id' => 2, 'name' => 'Test company 2' }
    ]
    stub_request(:get, "#{@wfh.url}/companies?page=1").
      with(headers: @headers).
        to_return(status: 200, body: JSON.dump(response), headers: {})
    output = "| \e[35mID\e[0m | \e[35mName          \e[0m |\n"
    output << "|----|----------------|\n"
    output << "| 1  | Test company   |\n"
    output << "| 2  | Test company 2 |\n"
    assert_equal @wfh.display_companies(1), output
  end

  def test_display_job
    response = {
      'id' => 1,
      'title' => 'Test title',
      'description' => 'Test description',
      'created_at' => '2015-01-07T21:51:36.000Z',
      'location' => '',
      'paid' => true,
      'application_info' => 'E-mail test@test.com',
      'company' => { 'id' => 1, 'name' => 'Test company' },
      'category' => { 'id' => 1, 'name' => 'Test category' }
    }
    stub_request(:get, "#{@wfh.url}/jobs/1").
      with(headers: @headers).
        to_return(status: 200, body: JSON.dump(response), headers: {})
    output = "\e[35mTitle\e[0m\nTest title @ Test company (1)\n"
    output << "\e[35mCategory\e[0m\nTest category (1)\n"
    output << "\e[35mPosted\e[0m\n2015-01-07 21:51\n"
    output << "\e[35mDescription\e[0m\nTest description\n"
    output << "\e[35mApplication Info\e[0m\nE-mail test@test.com\n"
    output << "\e[35mCountry\e[0m\nAnywhere\n"
    assert_equal @wfh.display_job(1), output
  end

  def test_display_jobs
    response = [
      { 'id' => 1,
        'title' => 'Test title',
        'created_at' => '2015-01-07T21:51:36.000Z',
        'company' => { 'id' => 1, 'name' => 'Test company' },
        'category' => { 'id' => 1, 'name' => 'Test category' }
      },
      { 'id' => 2,
        'title' => 'Test title 2',
        'created_at' => '2015-01-07T21:51:36.000Z',
        'company' => { 'id' => 2, 'name' => 'Test company 2' },
        'category' => { 'id' => 2, 'name' => 'Test category 2' }
      }
    ]
    stub_request(:get, "#{@wfh.url}/jobs?page=1").
      with(headers: @headers).
        to_return(status: 200, body: JSON.dump(response), headers: {})
    output = "| \e[35mID\e[0m | \e[35mPosted    \e[0m | \e[35mCategory           \e[0m | \e[35mCompany           \e[0m | \e[35mTitle       \e[0m |\n"
    output << "|----|------------|---------------------|--------------------|--------------|\n"
    output << "| 1  | 2015-01-07 | Test category (1)   | Test company (1)   | Test title   |\n"
    output << "| 2  | 2015-01-07 | Test category 2 (2) | Test company 2 (2) | Test title 2 |\n"
    assert_equal @wfh.display_jobs(1), output
  end
end
