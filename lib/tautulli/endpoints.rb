module Tautulli
  module Endpoints
    def home_stats
      make_request('get_home_stats')
    end

    def library
      make_request('get_libraries')
    end

    def libraries
      make_request('get_libraries_table')['data']
    end

    def library_media(library_id)
      params = {section_id: library_id}
      make_request('get_library_media_info', params)['data']
    end

    def recently_added(count = 50, type = nil)
      params = {count: count}
      params['media_type'] = type if type
      make_request('get_recently_added', params)['recently_added']
    end
  end
end