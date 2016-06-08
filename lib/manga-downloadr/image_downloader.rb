module MangaDownloadr
  class ImageDownloader < DownloadrClient
    def fetch(image_src, filename)
      File.delete(filename) if File.exists?(filename)
      http_get(image_src) do |response|
        case response.code
        #when "301"
          #fetch(response.headers["Location"], filename)
        when "200"
          File.open(filename, "w") do |f|
            f.print response.body
          end
        end
      end
#    rescue Net::HTTPGatewayTimeOut, Net::HTTPRequestTimeOut
#      puts 'WARNING: timeout in image_downloader'
#      sleep 1
#      fetch(image_src, filename)
    end
  end
end
