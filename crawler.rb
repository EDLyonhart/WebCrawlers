'''
Author: EDLyonhart 
  from tutorials:
    https://www.youtube.com/watch?v=mMHflTR-MuY
    https://www.youtube.com/watch?v=W_rEl19WIDg
    https://www.youtube.com/watch?v=WOkysoDl6SA
Date: 10 October 2016
'''

require 'mechanize'

class WebCrawler
  # Open and read 'file_name' (listed below)
  def initialize(file_name)
    @file = file_name
  end

  private
  # use 'check' method to only add unique URLs to file
  def save_site_crawl(site_url)
    begin
      if check(site_url)
        File.open(@file, "a") do |data|
          data.puts site_url
        end
      end

    rescue StandardError => error_message
      puts "ERROR: #{error_message}"
    end
  end

  # confirm that url is/isn't present in @file
  def check(url)
    data = File.read(@file)
    urls = data.split
    if urls.include? url
      return false
    else
      return true
    end
  end

  def fetch_database_urls
    active_urls = File.read(@file)
    urls = active_urls.split
    return urls
  end

  public
  def crawl
    links_found = 0
    agent = Mechanize.new

    agent.agent.http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    # get each url from file
    fetched_urls = fetch_database_urls()

    # each line of imported file to check within
    fetched_urls.each do |url_to_crawl|

      begin

        page = agent.get(url_to_crawl)

        links = page.links

        links.each do |link|
          
          # search for any 'href' value within returned 'link.attribute' xml object
          scraped_url = link.attributes['href']

          # ignore if href=#
          next if scraped_url == "#"

          # check for each opening case
          case scraped_url[0..4]
            when "https" then
              save_site_crawl(scraped_url)
              puts "Checking: #{scraped_url}\n---------------------------------------------\n"
            when "http:" then
              save_site_crawl(scraped_url)
              puts "Checking: #{scraped_url}\n---------------------------------------------\n"
            when "ftp:/" then
              save_site_crawl(scraped_url)
              puts "Checking: #{scraped_url}\n---------------------------------------------\n"
            else

            url_split = url_to_crawl.split("/")

            p "url_split = #{url_split}"

            # if scraped_url is a relative link (eg: '/home') do the following
            if scraped_url[0] == "/"
              # example: url_split = [\"https:\", \"\", \"services.bostonglobe.com\", \"pwd\", \"reset.asp\"]
              final_url = url_split[0] + "//" + url_split[2] + scraped_url
            else
              final_url = url_split[0] + "//" + url_split[2] + "/" + scraped_url
            end
            save_site_crawl(final_url)
            p "Checked: #{file}\n - - - - - - - - - - - - - - - - - \n"
          end

          links_found += 1

      end

      rescue StandardError => get_error
        puts "Request Level Error: #{get_error}"
      end
    end
    puts "Status Update:#{links_found} links found."
  end
end

crawler = WebCrawler.new('./urls.txt')
crawler.crawl