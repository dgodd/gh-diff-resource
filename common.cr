require "http/client"
require "json"
require "tempfile"
require "file"
require "process"

class Payload
  class Source
    JSON.mapping(
      repo: String,
      file: String,
      # username: String,
      # api_token: String,
    )
  end
  class Version
    JSON.mapping(
      ref: String?,
    )
  end

  JSON.mapping(
    source: Source,
    version: Version?,
  )

  def ref
    v = version
    if v.is_a?(Version)
      v.ref
    end
  end
end

class Release
  JSON.mapping(
    tag_name: String,
  )

  def self.latest(repo)
    response = HTTP::Client.get "https://api.github.com/repos/#{repo}/releases"
    releases = Array(Release).from_json(response.body)
    releases[0].tag_name
  end
end

class Commit
  JSON.mapping(
    sha: String,
  )

  def self.latest(repo)
    response = HTTP::Client.get "https://api.github.com/repos/#{repo}/commits"
    releases = Array(Commit).from_json(response.body)
    releases[0].sha
  end
end

def diff(repo, file, shas)
  files = shas.map do |sha|
    resp = HTTP::Client.get("https://raw.githubusercontent.com/#{repo}/#{sha}/#{file}")
    raise "Could not read file" unless resp.success?
    tempfile = Tempfile.new("gh-diff")
    File.write(tempfile.path, resp.body)
    tempfile
  end

  output = IO::Memory.new
  status = Process.run("diff", [ "-U", "0", "-b", files[0].path, files[1].path ], output: output)
  files.each { |f| f.unlink }

  {same: status.exit_code == 0, diff: output.to_s}
end
