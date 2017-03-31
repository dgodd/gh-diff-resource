require "./common"

payload = Payload.from_json(STDIN)

repo = payload.source.repo
shas = [Release.latest(repo), Commit.latest(repo)]

d = diff(repo, payload.source.file, shas)

if d[:same]
  puts [ payload.version ].to_json
else
  puts [ { "ref": shas.join(" ") } ].to_json
end
