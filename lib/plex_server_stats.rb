require 'plex-ruby'
require 'dotenv'
require 'time_diff'

Dotenv.load '../.env'

##
# Fetches server stats using Tautulli API if available, and falling back to Plex if not
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
    refresh if out_of_date?
  end

  def out_of_date?
    last_refresh.nil? || (Time.now - last_refresh) > 14_400
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
    if defined? TAUTULLI_CLIENT
      fetch_media_added_this_week_by_section_from_tautulli
    else
      fetch_media_added_this_week_by_section_from_plex
    end
  end

  def fetch_media_added_this_week_by_section_from_tautulli
    media_hash = Hash.new { |hash, key| hash[key] = [] }
    ['movie', 'show'].each do |type|
      TAUTULLI_CLIENT.recently_added(200, type).each do |media|
        next unless Time.at(media['added_at'].to_i) >= this_week
        next if media['media_type'] == 'season'
        section_title = media['library_name']
        media_object = OpenStruct.new(media)
        media_object.type = media_object.media_type
        media_hash[section_title] << media_object
      end
    end
    media_hash
  end

  def fetch_media_added_this_week_by_section_from_plex
    server.library.sections.each_with_object(Hash.new { |hash, key| hash[key] = [] }) do |section, hash|
      section.recently_added.each do |recent_addition|
        time_added = Time.at(recent_addition.added_at.to_i)
        break if time_added < this_week
        hash[section.title] << recent_addition
      end
    end
  end

  def collect_section_data
    if defined? TAUTULLI_CLIENT
      collect_section_data_from_tautulli
    else
      collect_section_data_from_plex
    end
  end

  def collect_section_data_from_tautulli
    TAUTULLI_CLIENT.libraries.each_with_object(Hash.new { |hash, key| hash[key] = {} }) do |section, hash|
      section_name = section['section_name']
      hash[:counts][section_name] = section['child_count'] || section['parent_count'] || section['count']
      hash[:duration][section_name] = section['duration']
    end
  end

  def collect_section_data_from_plex
    server.library.sections.each_with_object(Hash.new { |hash, key| hash[key] = {} }) do |section, hash|
      next if section.title == 'TV Shows'
      puts "Fetching #{section.title}"
      section_count = 0
      section_duration = 0
      section.all.each do |record|
        break if section_count > 5
        if record.is_a?(Plex::Show)
          record.seasons.each do |season|
            season.episodes.each do |episode|
              section_count += 1
              section_duration += episode.duration.to_f / 1000 if episode.respond_to?(:duration)
            end
          end
        else
          section_count += 1
          section_duration += record.duration.to_f / 1000
        end
      end
      hash[:counts][section.title] = "#{section_count} #{section.type}s"
      hash[:duration][section.title] = section_duration
    end
  end
end
