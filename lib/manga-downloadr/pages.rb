module MangaDownloadr
  class Pages < DownloadrClient
    def fetch(chapter_link)
      download_only chapter_link
      digest = uri_digest chapter_link
      fn = "tmp/pages-#{digest}"
      return File.read(fn).split("\n") if !@config.force_processing && File.exists?(fn)
      get chapter_link do |html|
        nodes = html.xpath("//div[@id='selectpage']//select[@id='pageMenu']//option")
        result = nodes.map { |node| [chapter_link, node.children.to_s].join("/") }
        File.write fn, result.join("\n")
        result
      end
    end
  end
end
