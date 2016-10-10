require 'mechanize'

class WebCrawler
  def initialize(file_name)
    @file = file_name
  end

  private
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
    artists_found = 0
    agent = Mechanize.new

    agent.agent.http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    fetched_urls = fetch_database_urls()

    fetched_urls.each do |url_to_crawl|

      begin

        if url_to_crawl == "http://corcoran.org/gallerytour/contents/"
          page = agent.get(url_to_crawl)

          links = page.links

          p "Corcoran currently showing the following artists:"

          links.each do |link|
            category = link.attributes['href']
            if category == "../contemporary" || 
              category == "../american" || 
              category == "../european" || 
              category == "../mixed-media"

                # save_site_crawl(link.to_s)
                p "- - - #{link.to_s}"
            end

            artists_found += 1
          end
        end

      rescue StandardError => get_error
        puts "Request Level Error: #{get_error}"
      end
    end
    puts "Status Update:#{artists_found} links found."
  end
end

crawler = WebCrawler.new('./museum_urls.txt')
crawler.crawl