require 'plex-ruby'
require 'dotenv'

Dotenv.load '../.env'

##
#
class PlexServerStats
  attr_reader :host, :port, :auth_token, :this_week, :last_refresh, :server

  def initialize(host, port, auth_token)
    @host = host
    @port = port
    @auth_token = auth_token
    @this_week = (Date.today - 7).to_time
    @last_refresh = nil
    create_plex_connection
  end

  def refresh_if_out_of_date
    refresh if last_refresh.nil? || (Time.now - last_refresh) > 14_400
  end

  def refresh
    @last_refresh = Time.now
    LOG.info 'Refreshing server stats'
    @media_added_this_week_by_section = nil
    @count_by_section = nil
  end

  def media_added_this_week_by_section
    @media_added_this_week_by_section ||= fetch_media_added_this_week_by_section
  end

  def count_by_section
    @count_by_section ||= fetch_counts_by_section
  end

  def user_count
    @user_count ||= fetch_user_count
  end

  private

  def create_plex_connection
    @server = Plex::Server.new(host, port)
    Plex.configure { |config| config.auth_token = @auth_token }
  end

  def fetch_media_added_this_week_by_section
    server.library.sections.each_with_object(Hash.new { |hash, key| hash[key] = [] }) do |section, hash|
      section.recently_added.each do |recent_addition|
        time_added = Time.at(recent_addition.added_at.to_i)
        break if time_added < this_week
        hash[section.title] << recent_addition
      end
    end
  end

  def fetch_counts_by_section
    server.library.sections.each_with_object({}) do |section, hash|
      hash[section.title] = "#{section.all.count} #{section.type}s"
    end
  end
end
