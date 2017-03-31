require "./common"
require "file"

payload = Payload.from_json(STDIN)
dir = ARGV[0]

repo = payload.source.repo
shas = payload.ref.to_s.split(' ')
raise "Version/Ref not supplied" unless shas.size == 2

d = diff(repo, payload.source.file, shas)
raise "Files were the same" if d[:same]

File.write("#{dir}/diff.txt", d[:diff])
File.write("#{dir}/sha_old", shas[0] + "\n")
File.write("#{dir}/sha_new", shas[1] + "\n")
puts [ { "version": { "ref": shas.join(" ") } } ].to_json
