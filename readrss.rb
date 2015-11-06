require 'rss'
require 'open-uri'
require 'nokogiri'
require 'mongoid'
require 'byebug'
require 'yaml'
Dir[File.expand_path(File.dirname(__FILE__)) + '/models/*.rb'].each {|file| require file }
@params = YAML.load(File.read "xpaths.yml")
@sites = ['vietnamnet']
Mongoid.load!("config.yml", :production)
@sites.each do |site_name|
  base = @params[site_name]['base']
  doc = Nokogiri::HTML(open(@params[site_name]['rss_link']))
  list = doc.xpath(@params[site_name]['list_link'])
  list.each do |link|
    url = base + link['href']
    open(url) do |rss|
      rss = open(url).read
      feed = RSS::Parser.parse(rss,false)
      puts "Title: #{feed.channel.title}"
      feed.items.each do |item|
        paper = Nokogiri::HTML(open(item.link.strip)) rescue ''
        content = paper.xpath(@params[site_name]['content']) if  paper.present?
        puts content if content.present?
      end 
    end
  end
end
