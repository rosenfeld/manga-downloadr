require 'digest'
require 'thread'

module MangaDownloadr
  class DownloadrClient
    def self.setup_http_pool(config)
      @@http_clients = SizedQueue.new(config.download_batch_size)
      config.download_batch_size.times do
        http_client = Net::HTTP.new(config.domain)
        http_client.keep_alive_timeout = 10
        @@http_clients << http_client
      end
    end

    def initialize(config)
      @config = config
    end

    def download_only(uri)
      http_get(uri, { "User-Agent": USER_AGENT }) if @config.download_only
    end

    def get(uri, &block)
      digest = uri_digest uri
      fn = "tmp/#{digest}"
      return block[Nokogiri::HTML(File.read fn)] if !@config.no_cache && File.exists?(fn)

      response = http_get(uri, { "User-Agent": USER_AGENT })
      case response.code
      when "301"
        get response.headers["Location"], &block
      when "200"
        File.write fn, response.body
        parsed = Nokogiri::HTML(response.body)
        block.call(parsed)
      else
        puts "unexpected code: #{response.code} - #{response.body} (#{uri})"
      end
    rescue Net::HTTPGatewayTimeOut, Net::HTTPRequestTimeOut
      puts 'WARNING: timeout in downloadr_client'
      # TODO: naive infinite retry, it will loop infinitely if the link really doesn't exist
      # so should have a way to control the amount of retries per link
      sleep 1
      get(uri, &block)
    end

    protected

    def http_get(*args)
      http_client = @@http_clients.pop
      http_client.get *args
    ensure
      @@http_clients << http_client
    end

    def uri_digest(uri)
      Digest::SHA256.hexdigest uri.to_s
    end
  end
end
