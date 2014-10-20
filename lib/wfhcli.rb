require 'json'
require 'rest-client'

URL = 'http://api.wfh-dev.io:3000'

def list_jobs(category_id=nil)
  if category_id == nil
    path = "/jobs"
  else
    path = "/categories/#{category_id}/jobs"
  end

  r = RestClient.get "#{URL}/#{path}", {:accept => :json}

  if r.code == 200
    jobs = JSON.parse(r)

    if jobs.size > 0
      content = []
      content[0] = ['ID', 'Category', 'Company', 'Title']

      jobs.each do |job|
        content << [job['id'], job['category']['name'], job['company']['name'], job['title']]
      end

      print_table(content)
    else
      puts "No jobs found"
    end
  end
end

def show_job(job_id)
  r = RestClient.get "#{URL}/jobs/#{job_id}", {:accept => :json}

  if r.code == 200
    job = JSON.parse(r)

    puts "#{'Title:'.rjust(17)} #{job['title']} @ #{job['company']['name']}"
    puts "#{'Category:'.rjust(17)} #{job['category']['name']}"
    puts "#{'Posted:'.rjust(17)} #{job['created_at']}"
    puts "#{'Description:'.rjust(17)}"
    puts job['description']
    puts "Application Info: #{job['application_info']}"
    puts "#{'Country:'.rjust(17)} #{job['country_id']}"
    puts "#{'Location:'.rjust(17)} #{job['location']}"
  end
end

def list_companies(page=nil)
  if page
    r = RestClient.get "#{URL}/companies?page=#{page}", {:accept => :json}
  else
    r = RestClient.get "#{URL}/companies", {:accept => :json}
  end

  if r.code == 200
    companies = JSON.parse(r)

    if companies.size > 0
      content = []
      content[0] = ['ID', 'Name', 'URL', 'Twitter']

      companies.each do |company|
        twitter = company['twitter'].nil? ? " " : company['twitter']
        content << [company['id'], company['name'], company['url'], twitter]
      end

      print_table(content)
    else
      puts "No companies found"
    end
  end
end

def print_table(content)
  cell_widths = Array.new(content[0].size, 0)

  content.each do |row|
    row.each_with_index do |cell, index|
      if cell.size > cell_widths[index]
        cell_widths[index] = cell.size
      end
    end
  end

  content.each_with_index do |row, row_index|
    if row_index == 1
      print "|"
      cell_widths.each do |c|
        # We use c + 2 to account for the spaces inside each cell
        print "-" * (c + 2)
        print "|"
      end
      puts
    end
    print "|"
    row.each_with_index do |cell, cell_index|
      print " #{cell.to_s.ljust(cell_widths[cell_index])} |"
    end
    puts
  end
end
