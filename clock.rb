require 'clockwork'
require './workers/inform_worker'

module Clockwork
  handler do |job|
    job.perform_async
  end

  every(1.day, InformWorker), :at => '07:00')
end
