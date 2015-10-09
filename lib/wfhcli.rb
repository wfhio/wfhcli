require 'date'
require 'json'
require 'rest-client'
require 'thor'

class WfhLib
  attr_accessor :title_colour, :url

  def initialize
    @shell = Thor::Shell::Color.new
    @title_colour = :magenta
    @url = 'https://www.wfh.io/api'
  end

  def categories
    get_json('/categories')
  end

  def company(id)
    get_json("/companies/#{id}")
  end

  def companies(page=1)
    uri = "/companies?page=#{page}"

    get_json(uri)
  end

  def display_categories
    categories = self.categories

    if categories.size > 0
      content = []
      content[0] = %w{ID Name}

      categories.each do |category|
        content << [category['id'], category['name']]
      end

      generate_table(content)
    else
      'No categories found'
    end
  end

  def display_company(company_id)
    content = []
    company = self.company(company_id)

    content << ['Name', company['name']]
    content << ['URL', company['url']]
    unless company['country'].nil?
      content << ['Headquarters', company['country']['name']]
    end
    unless company['twitter'].nil? || company['twitter'].empty?
      content << ['Twitter', company['twitter']]
    end
    unless company['showcase_url'].nil? || company['showcase_url'].empty?
      content << ['Showcase URL', company['showcase_url']]
    end

    return generate_header_and_body(content)
  end

  def display_companies(page)
    companies = self.companies(page)

    if companies.size > 0
      content = []
      content[0] = %w{ID Name}

      companies.each do |company|
        content << [company['id'], company['name']]
      end

      generate_table(content)
    else
      'No companies found'
    end
  end

  def display_job(job_id)
    content = []
    job = self.job(job_id)

    if job['country'].nil? || job['country'].empty?
      country = 'Anywhere'
    else
      country = job['country']['name']
    end

    title = "#{job['title']} @ #{job['company']['name']} " \
            "(#{job['company']['id']})"
    category = "#{job['category']['name']} (#{job['category']['id']})"
    posted = format_date(job['created_at'], true)

    content << ['Title', title]
    content << ['Category', category]
    content << ['Posted', posted]
    content << ['Description', job['description']]
    content << ['Application Info', job['application_info']]
    content << ['Country', country]
    unless job['location'].nil? || job['location'].empty?
      content << ['Location', job['location']]
    end
    source = "#{job['source']['name']} (#{job['source']['id']})"
    content << ['Source', source]

    return generate_header_and_body(content)
  end

  def display_jobs(page, category_id=nil, source_id=nil)
    jobs = self.jobs(page, category_id, source_id)

    if jobs.size > 0
      content = []
      content[0] = %w{ID Posted Category Company Title}

      jobs.each do |job|
        content << [job['id'],
                    format_date(job['created_at']),
                    "#{job['category']['name']} (#{job['category']['id']})",
                    "#{job['company']['name']} (#{job['company']['id']})",
                    truncate(job['title'], 30)]
      end

      generate_table(content)
    else
      'No jobs found'
    end
  end

  def display_sources
    categories = self.sources

    if sources.size > 0
      content = []
      content[0] = %w{ID Name URL}

      sources.each do |source|
        content << [source['id'], source['name'], source['url']]
      end

      generate_table(content)
    else
      'No sources found'
    end
  end

  def job(id)
    get_json("/jobs/#{id}")
  end

  def jobs(page=1, category_id=nil, source_id=nil)
    uri = "/jobs?page=#{page}&"
    unless category_id.nil?
      uri = uri + "category_id=#{category_id}&"
    end
    unless source_id.nil?
      uri = uri + "source_id=#{source_id}"
    end

    get_json(uri)
  end

  def sources
    get_json('/sources')
  end

  private

  def format_date(str, inc_time=false)
    format = '%Y-%m-%d'
    format = format + ' %H:%M' if inc_time == true
    d = DateTime.parse(str)
    d.strftime(format)
  end

  def generate_header_and_body(content)
    output = ''

    content.each do |header, body|
      output << "#{@shell.set_color(header, @title_colour)}\n#{body}\n"
    end

    return output
  end

  def generate_table(content)
    cell_widths = Array.new(content[0].size, 0)

    # We do cell.to_s.size as cell could be an integer and 8.size == 8,
    # which is not what we want.
    content.each do |row|
      row.each_with_index do |cell, index|
        if cell.to_s.size > cell_widths[index]
          cell_widths[index] = cell.to_s.size
        end
      end
    end

    lines = ''

    content.each_with_index do |row, row_index|
      if row_index == 1
        lines << '|'
        cell_widths.each do |c|
          # We use c + 2 to account for the spaces inside each cell
          lines << '-' * (c + 2)
          lines << '|'
        end
        lines << "\n"
      end
      lines << '|'
      row.each_with_index do |cell, cell_index|
        formatted = cell.to_s.ljust(cell_widths[cell_index])

        if row_index == 0
          lines << " #{@shell.set_color(formatted, @title_colour)} |"
        else
          lines << " #{formatted} |"
        end
      end
      lines << "\n"
    end

    return lines
  end

  def get_json(uri)
    begin
      # TODO: add wfhcli version to user_agent string
      r = RestClient.get("#{@url}#{uri}",
                         { accept: :json, user_agent: 'wfhcli' })
    rescue RestClient::ResourceNotFound
      puts "The resource #{uri} was not found"
      exit!
    rescue => e
      puts e
      exit!
    else
      JSON.parse(r)
    end
  end

  def truncate(str, len)
    if str.size > len
      str[0..(len - 4)] + '...'
    else
      str
    end
  end
end
