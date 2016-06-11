def media_server(ip: nil, port: nil, protocol: 'http')
  ip = SERVER_IP_ADDRESS if ip.nil? && defined?(SERVER_IP_ADDRESS)
  "#{protocol}://#{ip}:#{port}/"
end
