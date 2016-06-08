module MangaDownloadr
  class PageImage < DownloadrClient
    def fetch(page_link)
      download_only page_link
      digest = uri_digest page_link
      fn = "tmp/page-image-#{digest}"
      if !@config.force_processing && File.exists?(fn)
        image_src = File.read(fn).chomp
        uri = URI.parse(image_src)
        return Image.new(uri.host, uri.path, "#{title_name}-Chap-#{chapter_number}-Pg-#{page_number}.#{extension}")
      end
      get page_link do |html|
        images = html.css('#img')

        image_alt = images[0]["alt"]
        image_src = images[0]["src"]

        if image_alt && image_src
          extension      = image_src.split(".").last
          list           = image_alt.split(" ").reverse
          title_name     = list[4..-1].join(" ")
          chapter_number = list[3].rjust(5, '0')
          page_number    = list[0].rjust(5, '0')

          File.write fn, image_src
          uri = URI.parse(image_src)
          Image.new(uri.host, uri.path, "#{title_name}-Chap-#{chapter_number}-Pg-#{page_number}.#{extension}")
        else
          puts "failed to find metadata for #{page_link}"
          raise Exception.new("Couldn't find proper metadata alt in the image tag")
        end
      end
    end
  end
end
