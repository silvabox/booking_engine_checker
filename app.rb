require 'sinatra'
require './lib/uptime'

get '/' do
  haml :index
end

get '/api/last_seven_days' do
  chart_json(Uptime.last_seven_days.by_day.percentages)
end


def chart_json(uptime)
  {
    labels: uptime.keys,
    data: uptime.values
  }.to_json
end
