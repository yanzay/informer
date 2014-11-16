require 'rss'
require 'open-uri'
require 'sqlite3'

class HabraReader
  RUBY_URL = 'http://habrahabr.ru/rss/hub/ruby/ac69d26a3693b97a3aa275b467152c73/'
  RAILS_URL = 'http://habrahabr.ru/rss/hub/ror/ac69d26a3693b97a3aa275b467152c73/'

  def initialize
    @db = SQLite3::Database.new 'topics.db'
  end

  def text
    ruby_items = read(RUBY_URL)
    rails_items = read(RAILS_URL)
    ruby_items.each {|item| save_item(item, :ruby)}
    rails_items.each {|item| save_item(item, :rails)}
    unread_items
  end

  def read(url)
    open(url, "User-Agent" => "Chrome") do |rss|
      feed = RSS::Parser.parse(rss, false)
      feed.items.first(10).map do |item|
        {link: item.guid.content, title: item.title}
      end
    end
  end

  private

  def save_item(item, type)
    count = @db.execute("SELECT COUNT(*) FROM items WHERE link = '#{item[:link]}'").flatten.first
    p count
    if count == 0
      @db.execute "INSERT INTO items (link, title, type, listened) VALUES (?, ?, ?, 0)", [item[:link], item[:title], type.to_s]
    end
  end

  def unread_items
    @db.execute "SELECT * FROM items"
  end
end

p HabraReader.new.text
