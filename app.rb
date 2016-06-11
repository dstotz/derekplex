$LOAD_PATH.unshift './lib'

require 'bundler/setup'
require 'sinatra'
require 'logger'
require 'base'

LOG = Logger.new(STDOUT)

before '*' do
  redirect request.url.sub(%r{^http://}, 'https://') unless request.secure? || request.host == 'localhost'
end

get '/' do
  erb :index
end

get '/plex' do
  redirect to 'https://app.plex.tv/web/app'
end

get '/changelog' do
  erb :changelog
end

get '/requests' do
  redirect to media_server(port: 3000)
end

get '/monitor' do
  redirect to media_server(port: 8181)
end

get '/stats' do
  erb :stats
end
