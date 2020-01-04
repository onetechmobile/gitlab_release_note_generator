require 'faraday'
require 'json'

conn = Faraday.new(:url => 'https://gitlab.com/api/v4/projects/16087798') do |faraday|
    faraday.headers['PRIVATE-TOKEN'] = 'Mozsks-bdJEAk1C8KJsq'
end

response = conn.get 'https://gitlab.com/api/v4/projects/16087798/merge_requests'
parsed_json = JSON.parse(response.body)

# puts parsed_json
merge_request_titles = ""

for el in parsed_json
    merge_request_titles += el["title"] + '\n'
end

releaseResponse = conn.post do |req|
    req.url 'https://gitlab.com/api/v4/projects/16087798/releases'
    req.headers['Content-Type'] = 'application/json'
    req.body = '{ "name": "New release2", "tag_name": "v1.1", "description": "Super nice release2"}'
end

puts releaseResponse.body


module GitlabReleaseNoteGenerator

    class Builder
        def self.testFunc(someword)
            someword
        end
    end
end