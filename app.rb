$LOAD_PATH.unshift './lib'

require 'bundler/setup'
require 'sinatra'
require 'logger'
require 'base'
require 'plex_server_stats'
require 'tautulli'
require 'dotenv'

Dotenv.load

LOG = Logger.new(STDOUT)

if ENV['TAUTULLI_API_KEY']
  TAUTULLI_CLIENT = Tautulli::Client.new(
    ENV['SERVER_IP_ADDRESS'],
    ENV['TAUTULLI_PORT'],
    ENV['TAUTULLI_API_KEY']
  )
end

SERVER_STATS = PlexServerStats.new(
  ENV['SERVER_IP_ADDRESS'],
  ENV['SERVER_PORT'],
  ENV['SERVER_AUTH_TOKEN']
)

SERVER_STATS.media_added_this_week_by_section

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

# Tautulli (formerlly PlexPy)
get '/monitor' do
  redirect to media_server(port: ENV['TAUTULLI_PORT'])
end

# Sonarr
get '/sonarr' do
  redirect to media_server(port: ENV['SONARR_PORT'])
end

# Sonarr
get '/radarr' do
  redirect to media_server(port: ENV['RADARR_PORT'])
end

# Plex Webtools Channel
get '/webtools' do
  redirect to media_server(port: ENV['WEBTOOLS_PORT'])
end

# Plex server stats using Plex API
get '/stats' do
  SERVER_STATS.refresh_if_out_of_date
  erb :stats
end

get '/refresh-stats' do
  SERVER_STATS.refresh
  redirect to '/stats'
end

# Plex It tutorial
get '/plex-it' do
  erb :plex_it
end
