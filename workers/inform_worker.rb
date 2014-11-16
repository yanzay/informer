require 'sidekiq'
require_relative '../app.rb'

class InformWorker
  include Sidekiq::Worker

  def perform
    Weather.new.inform
  end
end
