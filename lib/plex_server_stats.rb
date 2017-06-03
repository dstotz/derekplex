require 'plex-ruby'
require 'dotenv'
require 'time_diff'

Dotenv.load '../.env'

##
#
class PlexServerStats
  TIME_DURATION_FORMAT = '%y, %M, %w, %d, %H, %N, and %S'

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
    @collection_data = nil
  end

  def media_added_this_week_by_section
    @media_added_this_week_by_section ||= fetch_media_added_this_week_by_section
  end

  def count_by_section
    @count_by_section ||= collection_data[:counts]
  end

  def user_count
    @user_count ||= fetch_user_count
  end

  def collection_data
    @collection_data ||= collect_section_data
  end

  ##
  # Returns an array of each section in your library by its duration in minutes
  def duration_by_section
    @library_duration ||= collection_data[:duration]
  end

  ##
  # Returns the total duration of all media in all libraries in hours
  def total_library_duration
    library_duration = 0
    duration_by_section.each do |_section, duration|
      library_duration += duration
    end
    time_diff_components = Time.diff(Time.now, Time.now + library_duration, TIME_DURATION_FORMAT)[:diff]
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

  def collect_section_data
    server.library.sections.each_with_object(Hash.new { |hash, key| hash[key] = {} }) do |section, hash|
      puts "Fetching #{section.title}"
      section_count = 0
      section_duration = 0
      section.all.each do |record|
        section_duration += record.duration.to_f / 1000
        section_count += 1
      end
      hash[:counts][section.title] = "#{section_count} #{section.type}s"
      hash[:duration][section.title] = section_duration
    end
  end
end
