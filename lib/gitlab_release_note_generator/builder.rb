require 'faraday'
require 'json'
require 'date'

module GitlabReleaseNoteGenerator
    class Builder
        @@base_url = 'https://'

        def main(host_name, private_token, project_id)       
            @@base_url << "#{host_name}/api/v4/projects/#{project_id}"
            conn = Faraday.new(:url => @@base_url) do |faraday|
                faraday.headers['PRIVATE-TOKEN'] = private_token
            end
            get_tags(conn)
        end

        def get_tags(conn) 
            response = conn.get @@base_url + '/repository/tags'
            tags_dict = JSON.parse(response.body)
            tag_name = tags_dict[0]["name"]

            if tags_dict.count > 1 
                get_all_merge_requests_after(conn, tags_dict[1]["commit"]["created_at"], tag_name)
            else
                get_all_merge_request_before(conn, tags_dict[0]["commit"]["created_at"], tag_name)    
            end
        end

        def get_all_merge_request_before(conn, datetime, tag) 
            response = conn.get @@base_url + "/merge_requests?created_before=#{datetime}"
            generate_changelog(conn, response.body, tag)
        end

        def get_all_merge_requests_after(conn, datetime, tag)
            response = conn.get @@base_url + "/merge_requests?created_after=#{datetime}"
            generate_changelog(conn, response.body, tag)
        end

        def generate_changelog(conn, response_body, tag)  
            merge_requests = JSON.parse(response_body)
            description = '### Merged merge requests (%s)\r\n#### Closed merge requests\r\n'
            description = description % [getCurrentTime]
            for merge in merge_requests
                description += "- #{merge["title"]} " + "[#{merge["reference"]}]" + "(#{merge["web_url"]})"
                description += " [#{merge["author"]["username"]}]" + "(#{merge["author"]["web_url"]})" + '\r\n'
            end    
            
            post_new_release(conn, description, tag)
        end 

        def post_new_release(conn, description, tag) 
            body = '{ "name":  "%s", "tag_name": "%s", "description": "%s"}'
            res_body = body % [tag, tag, description]
            puts res_body
            response = conn.post do |req|
                req.url @@base_url + '/releases'
                req.headers['Content-Type'] = 'application/json'
                req.body = res_body
            end
            
            puts response.status, response.body
        end

        def getCurrentTime
            current_time = Time.now.strftime("%d.%m.%Y")
            return current_time
        end
    end
end