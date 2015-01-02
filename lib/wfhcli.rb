require 'date'
require 'json'
require 'rest-client'
require 'thor'

class WfhLib
  TITLE_COLOUR = :magenta
  URL = 'https://www.wfh.io/api'

  def initialize
    @shell = Thor::Shell::Color.new
  end

  # TODO: Make private once we are able to properly test methods which use
  #       use this method.
  def format_date(str)
    d = Date.parse(str)
    d.strftime("%Y-%m-%d")
  end

  # TODO: Make private once we are able to properly test methods which use
  #       use this method.
  def generate_table(content)
    cell_widths = Array.new(content[0].size, 0)

    # We do cell.to_s.size as cell could be an integer and 8.size == 8, which is
    # not what we want.
    content.each do |row|
      row.each_with_index do |cell, index|
        if cell.to_s.size > cell_widths[index]
          cell_widths[index] = cell.to_s.size
        end
      end
    end

    lines = ""

    content.each_with_index do |row, row_index|
      if row_index == 1
        lines << "|"
        cell_widths.each do |c|
          # We use c + 2 to account for the spaces inside each cell
          lines << "-" * (c + 2)
          lines << "|"
        end
        lines << "\n"
      end
      lines << "|"
      row.each_with_index do |cell, cell_index|
        formatted = cell.to_s.ljust(cell_widths[cell_index])

        if row_index == 0
          lines << " #{@shell.set_color(formatted, TITLE_COLOUR)} |"
        else
          lines << " #{formatted} |"
        end
      end
      lines << "\n"
    end

    return lines
  end

  # TODO: Make private once we are able to properly test methods which use
  #       use this method.
  def get_json(uri)
    begin
      r = RestClient.get "#{URL}#{uri}", {:accept => :json}
    rescue => e
      puts e
      exit!
    else
      JSON.parse(r)
    end
  end

  def list_categories
    categories = get_json('/categories')

    if categories.size > 0
      content = []
      content[0] = ['ID', 'Name']

      categories.each do |category|
        content << [category['id'], category['name']]
      end

      puts generate_table(content)
    else
      puts 'No categories found'
    end
  end

  def list_companies(page=nil)
    uri = '/companies'
    uri = uri + "?page=#{page}" if page

    companies = get_json(uri)

    if companies.size > 0
      content = []
      content[0] = ['ID', 'Name']

      companies.each do |company|
        content << [company['id'], company['name']]
      end

      puts generate_table(content)
    else
      puts 'No companies found'
    end
  end

  def list_jobs(page=nil, category_id=nil)
    if category_id == nil
      uri = '/jobs'
      uri = uri + "?page=#{page}" if page
    else
      uri = "/categories/#{category_id}/jobs"
      uri = uri + "?page=#{page}" if page
    end

    jobs = get_json(uri)

    if jobs.size > 0
      content = []
      content[0] = ['ID', 'Posted', 'Category', 'Company', 'Title']

      jobs.each do |job|
        content << [job['id'],
                    format_date(job['created_at']),
                    "#{job['category']['name']} (#{job['category']['id']})",
                    "#{job['company']['name']} (#{job['company']['id']})",
                    truncate(job['title'], 30)]
      end

      puts generate_table(content)
    else
      puts 'No jobs found'
    end
  end

  # TODO: Make private once we are able to properly test methods which use
  #       use this method.
  def generate_header_and_body(title, body)
    "#{@shell.set_color(title, TITLE_COLOUR)}\n#{body}"
  end

  def show_company(company_id)
    company = get_json("/companies/#{company_id}")

    puts generate_header_and_body('Name', company['name'])
    puts generate_header_and_body('URL', company['url'])
    unless company['twitter'].nil? or company['twitter'].empty?
      puts generate_header_and_body('Twitter', company['twitter'])
    end
    unless company['showcase_url'].nil? or company['showcase_url'].empty?
      puts generate_header_and_body('Showcase URL', company['showcase_url'])
    end
  end

  def show_job(job_id)
    job = get_json("/jobs/#{job_id}")
    if job['country'].nil? or job['country'].empty?
      country = 'Anywhere'
    else
      country = job['country']['name']
    end

    puts generate_header_and_body('Title', "#{job['title']} @ #{job['company']['name']}")
    puts generate_header_and_body('Category', "#{job['category']['name']} (#{job['category']['id']})")
    puts generate_header_and_body('Posted', job['created_at'])
    puts generate_header_and_body('Description', job['description'])
    puts generate_header_and_body('Application Info', job['application_info'])
    puts generate_header_and_body('Country', country)
    unless job['location'].nil? or job['location'].empty?
      puts generate_header_and_body('Location', job['location'])
    end
  end

  # TODO: Make private once we are able to properly test methods which use
  #       use this method.
  def truncate(str, len)
    if str.size > len
      str[0..(len-4)] + "..."
    else
      str
    end
  end
end
