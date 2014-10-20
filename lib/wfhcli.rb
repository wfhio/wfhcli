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
      widths = find_widths(jobs)

      puts "#{'ID'.ljust(5)} " +
           "#{'Category'.ljust(widths['category']['name'])} " +
           "#{'Company'.ljust(widths['company']['name'])} " +
           "#{'Title'.ljust(widths['title'])}"

      jobs.each do |job|
        puts "#{job['id'].to_s.ljust(5)}" +
             "#{job['category']['name'].ljust(widths['category']['name'])} " +
             "#{job['company']['name'].ljust(widths['company']['name'])} " +
             "#{job['title'].ljust(widths['title'])}"
      end
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
      widths = find_widths(companies)

      puts "#{'ID'.ljust(5)} " +
           "#{'Name'.ljust(widths['name'])} " +
           "#{'URL'.ljust(widths['url'])} " +
           "#{'Twitter'.ljust(widths['twitter'])}"

      companies.each do |company|
        twitter = company['twitter'].nil? ? " " : company['twitter']
        puts "#{company['id'].to_s.ljust(5)} " +
             "#{company['name'].ljust(widths['name'])} " +
             "#{company['url'].ljust(widths['url'])} " +
             "#{twitter.ljust(widths['twitter'])}"
      end
    else
      puts "No companies found"
    end
  end
end

def find_widths(json)
  widths = {}

  json.each do |entry|
    widths = walk_hash(widths, entry)
  end

  return widths
end

def walk_hash(widths, entry)
  entry.each do |key, value|
    if value.is_a?(Hash)
      if not widths[key]
        widths[key] = {}
      end
      walk_hash(widths[key], value)
    else
      if widths[key]
        if value && value.size > widths[key]
          widths[key] = value.size + 1
        end
      else
        if value
          widths[key] = value.size + 1
        end
      end
    end
  end

  return widths
end
