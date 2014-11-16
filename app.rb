# encoding: utf-8

require 'net/http'
require 'json'
require 'date'
require 'time'

class Weather
  KIEV_ID = 924938
  BASE_URL = 'https://query.yahooapis.com/v1/public/yql?q='

  def get
    query = "select * from weather.forecast where woeid=#{KIEV_ID} and u='c'"
    query << "&format=json"
    url = URI.encode(BASE_URL + query)
    response = Net::HTTP.get(URI.parse(url))
    JSON.parse(response)
  end

  def inform
    data = get
    today = data["query"]["results"]["channel"]["item"]["forecast"].first
    puts today
    high, low = today["high"], today["low"]
    text = today["text"]
    puts "code: #{today["code"]}"
    results = []
    results << "#{hello}, мой господин."
    results << "Киевское время #{Time.now.hour}:#{'%02d' % Time.now.min}."
    results << "Сегодня #{day_of_week}, #{Date.today.day}-е #{month}, в Киеве ожидается. #{status_from_code(today['code'].to_i)}"
    results << "температура воздуха от #{low} до #{high} градусов цельсия."
    results << "Хорошего дня."
    puts results
    say(results)
  end

  def say(texts)
    # system("mplayer alarm.mp3 -af volume=1 &")
    # system("mpc load morning.m3u")
    # system("mpc play")

    texts.each_with_index do |text, index|
      system("wget -q -U Mozilla \"http://translate.google.com/translate_tts?ie=UTF-8&tl=ru&q=#{text}\" -O output#{index}.mp3")
    end

    texts.each_with_index do |_, index|
      system("mplayer output#{index}.mp3 -af volume=8 > /dev/null")
    end
  end

  private

  def hello
    if Time.now < Time.new(Time.now.year, Time.now.month, Time.now.day, 12, 00)
      "Доброе утро"
    elsif Time.now < Time.new(Time.now.year, Time.now.month, Time.now.day, 18, 00)
      "Добрый день"
    else
      "Добрый вечер"
    end
  end

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
      28 => "облачная погода с прояснениями",
      29 => "облачная погода с прояснениями",
      30 => "облачная погода с прояснениями"
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

  def month
    months = {
      1 => "января",
      2 => "февраля",
      3 => "марта",
      4 => "апреля",
      5 => "мая",
      6 => "июня",
      7 => "июля",
      8 => "августа",
      9 => "сентября",
      10 => "октября",
      11 => "ноября",
      12 => "декабря"
    }
    months[Date.today.month]
  end

  def day_of_month
    I18n.with_locale(:ru) { Date.today.day.to_words(gender: :neuter) }
  end
end
