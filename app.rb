$LOAD_PATH.unshift './lib'

require 'bundler/setup'
require 'sinatra'
require 'logger'
require 'base'
require 'dotenv'

Dotenv.load

LOG = Logger.new(STDOUT)

before '*' do
  redirect request.url.sub(%r{^http://}, 'https://') unless request.secure? || request.host == 'localhost'
end

get '/' do
  erb :index
end

# Plex web app
get '/plex' do
  redirect to 'https://app.plex.tv/web/app'
end

get '/changelog' do
  erb :changelog
end

# Plex Requests
get '/requests' do
  redirect to media_server(port: ENV['PLEX_REQUEST_PORT'])
end

# PlexPy
get '/monitor' do
  redirect to media_server(port: ENV['PLEXPY_PORT'])
end

get '/stats' do
  erb :stats
end
