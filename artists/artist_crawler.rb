'''
Author: EDLyonhart 
  from tutorials:
    https://www.youtube.com/watch?v=mMHflTR-MuY
    https://www.youtube.com/watch?v=W_rEl19WIDg
    https://www.youtube.com/watch?v=WOkysoDl6SA
Date: 10 October 2016

This version of the crawler is looking for artists currently on display at given museums.
'''

require 'mechanize'

class WebCrawler
  def initialize(read_file, write_file)
    @museums = read_file
    @artist_on_display = write_file
  end

  private
  def save_artist_crawl(artist)
    begin
      if check(artist)
        File.open(@artist_on_display, "a") do |data|
          data.puts artist
        end
      end

    rescue StandardError => error_message
      puts "ERROR: #{error_message}"
    end
  end

  def check(artist)
    data = File.read(@artist_on_display)
    artists = data.split
    if artists.include? artist
      return false
    else
      return true
    end
  end

  def fetch_database_urls
    active_urls = File.read(@museums)
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

              artist = link.to_s

              if artist[-1] !~ /[[:alpha:]]/
                p artist
                artist = artist[0..-2]
              end

                save_artist_crawl(artist)
                p "- - - #{artist}"
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

crawler = WebCrawler.new('./museum_urls.txt', './artists_on_display.txt')
crawler.crawl