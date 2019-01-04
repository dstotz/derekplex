require 'tautulli/endpoints'
require 'httparty'

module Tautulli
  class Client
    include Tautulli::Endpoints

    API_VERSION = 2

    def initialize(server_address, tautulli_port, tautulli_api_key = nil)
      @server_address = server_address
      @tautulli_port = tautulli_port
      @tautulli_api_key = tautulli_api_key
    end

    def get_api_key(username, password)
      params = {username: username, password: password}
      @tautulli_api_key = make_request('get_apikey', params)
      puts "API key is #{@tautulli_api_key}"
    end

    def enable_sql!
      api_sql
      @sql_enabled = true
    end

    def make_request(endpoint, params = {})
      uri = base_uri
      uri.query = query_params(endpoint, params)
      response = HTTParty.get(uri)
      raise HTTParty::Error.new(response.to_s) unless response.success?
      response['response']['data']
    end

    private

    def query_params(endpoint, params = {})
      params.merge!({apikey: @tautulli_api_key, cmd: endpoint})
      URI.encode_www_form(params)
    end

    def base_uri
      @base_uri ||= URI.join("http://#{@server_address}:#{@tautulli_port}", "api/v#{API_VERSION}")
    end
  end
end
