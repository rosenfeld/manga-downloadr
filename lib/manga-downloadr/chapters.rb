module MangaDownloadr
  class Chapters < DownloadrClient
    def initialize(config)
      @root_uri = config.root_uri
      super(config)
    end

    def fetch
      download_only @root_uri
      digest = uri_digest @root_uri
      fn = "tmp/chapters-#{digest}"
      return File.read(fn).split("\n") if !@config.force_processing && File.exists?(fn)
      get @root_uri do |html|
        nodes = html.css("#listing a")
        result = nodes.map { |node| node["href"] }
        File.write fn, result.join("\n")
        result
      end
    end
  end
end
