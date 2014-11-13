require 'net/http'
require 'json'
require 'date'
require 'i18n'
require 'numbers_and_words'

class Weather
  KIEV_ID = 924938
  BASE_URL = 'https://query.yahooapis.com/v1/public/yql?q='

  def get
    query = "select * from weather.forecast where woeid=#{KIEV_ID} and u='c'"
    query << "&format=json"
    url = URI.encode(BASE_URL + query)
    response = Net::HTTP.get(URI(url))
    JSON.parse(response)
  end

  def inform
    data = get
    today = data["query"]["results"]["channel"]["item"]["forecast"].first
    puts today
    high, low = today["high"], today["low"]
    text = today["text"]
    puts "code: #{today["code"]}"
    puts [high, low]
    result = "Сегодня #{day_of_week}, #{day_of_month}, в Киеве ожидается #{status_from_code(today['code'].to_i)}, температура воздуха от #{low} до #{high} градусов Цельсия."
    say result
  end

  def say(text)
    exec("wget -q -U Mozilla \"http://translate.google.com/translate_tts?ie=UTF-8&tl=ru&q=#{text}\" -O - | mplayer -cache 8192 -")
  end

  private

  def status_from_code(code)
    statuses = {
      0 => "торнадо",
      1 => "тропический шторм",
      2 => "ураган",
      5 => "снег с дождём",
      6 => "дождь с мокрым снегом",
      7 => "мокрый снег",
      11 => "дождь",
      12 => "дождь",
      16 => "снег",
      26 => "облачная погода",
      28 => "облачная погода с прояснениями"
    }
    statuses[code]
  end

  def day_of_week
    days = {
      1 => "понедельник",
      2 => "вторник",
      3 => "среда",
      4 => "четверг",
      5 => "пятница",
      6 => "суббота",
      7 => "воскресенье"
    }
    days[Date.today.cwday]
  end

  def day_of_month
    I18n.with_locale(:ru) { Date.today.day.to_words(gender: :neuter) }
  end
end

Weather.new.inform
