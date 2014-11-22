require 'date'
require 'json'
require 'rest-client'

URL = 'https://www.wfh.io/api'

module Wfh
  class Lib
    def self.format_date(str)
      d = Date.parse(str)
      d.strftime("%Y-%m-%d")
    end

    def self.generate_table(content)
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
          lines << " #{cell.to_s.ljust(cell_widths[cell_index])} |"
        end
        lines << "\n"
      end

      return lines
    end

    def self.get_json(uri)
      begin
        r = RestClient.get "#{URL}#{uri}", {:accept => :json}
      rescue => e
        puts e
        exit!
      else
        JSON.parse(r)
      end
    end

    def self.list_categories()
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

    def self.list_companies(page=nil)
      uri = '/companies'
      uri = uri + "?page=#{page}" if page

      companies = get_json(uri)

      if companies.size > 0
        content = []
        content[0] = ['ID', 'Name', 'URL', 'Twitter']

        companies.each do |company|
          twitter = company['twitter'].nil? ? " " : company['twitter']
          content << [company['id'], company['name'], company['url'], twitter]
        end

        puts generate_table(content)
      else
        puts 'No companies found'
      end
    end

    def self.list_jobs(category_id=nil)
      if category_id == nil
        uri = '/jobs'
      else
        uri = "/categories/#{category_id}/jobs"
      end

      jobs = get_json(uri)

      if jobs.size > 0
        content = []
        content[0] = ['ID', 'Posted', 'Category', 'Company', 'Title']

        jobs.each do |job|
          content << [job['id'],
                      format_date(job['created_at']),
                      job['category']['name'],
                      job['company']['name'],
                      truncate(job['title'], 30)]
        end

        puts generate_table(content)
      else
        puts 'No jobs found'
      end
    end

    def self.show_job(job_id)
      job = get_json("/jobs/#{job_id}")

      puts "#{'Title:'.rjust(17)} #{job['title']} @ #{job['company']['name']}"
      puts "#{'Category:'.rjust(17)} #{job['category']['name']}"
      puts "#{'Posted:'.rjust(17)} #{job['created_at']}"
      puts "#{'Description:'.rjust(17)}"
      puts job['description']
      puts "Application Info: #{job['application_info']}"
      puts "#{'Country:'.rjust(17)} #{job['country_id']}"
      puts "#{'Location:'.rjust(17)} #{job['location']}"
    end

    def self.truncate(str, len)
      if str.size > len
        str[0..(len-4)] + "..."
      else
        str
      end
    end
  end
end
