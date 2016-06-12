def media_server(ip: nil, port: nil, protocol: 'http')
  server_ip = ip || ENV['SERVER_IP_ADDRESS']
  construct_uri(protocol, server_ip, port)
end

def construct_uri(protocol, host, port)
  return '/' if host.nil?
  uri = "#{protocol}://#{host}"
  uri += ":#{port}" if port
  uri
end
