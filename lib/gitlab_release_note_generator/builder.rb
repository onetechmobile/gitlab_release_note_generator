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
                merged_requests = get_all_merge_requests_after(conn, tags_dict[1]["commit"]["created_at"])
                closed_issues = get_all_issues_after(conn, tags_dict[1]["commit"]["created_at"])
                generate_changelog(conn, tag_name, merged_requests, closed_issues)
            else
                merged_requests = get_all_merge_request_before(conn, tags_dict[0]["commit"]["created_at"])    
                closed_issues = get_all_issues_before(conn, tags_dict[0]["commit"]["created_at"]) 
                generate_changelog(conn, tag_name, merged_requests, closed_issues)
            end            
        end

        def get_all_merge_request_before(conn, datetime) 
            response = conn.get @@base_url + "/merge_requests?created_before=#{datetime}?state=merged?scope=all"
            return response.body
        end

        def get_all_merge_requests_after(conn, datetime)
            response = conn.get @@base_url + "/merge_requests?created_after=#{datetime}?state=merged?scope=all"
            return response.body
        end

        def get_all_issues_before(conn, datetime)
            response = conn.get @@base_url + "/issues?created_before=#{datetime}?state=closed?scope=all"    
            return response.body
        end

        def get_all_issues_after(conn, datetime) 
            response = conn.get @@base_url + "/issues?created_after=#{datetime}?state=closed?scope=all" 
            return response.body
        end 

        def generate_changelog(conn, tag, merged_requests_response_body, closed_issues_response_body)  
            merged_requests = JSON.parse(merged_requests_response_body)
            closed_issues = JSON.parse(closed_issues_response_body)
            description = '### Release note (%s)\r\n'
            description = description % [getCurrentTime]        

            closed_issues_notes = generate_closed_issues_notes(conn, closed_issues)
            merged_requests_notes = generate_merged_requests_notes(conn, merged_requests)   
            
            if closed_issues_notes.nil? && merged_requests_notes.nil? 
                puts "Didn't find either closed issues or merged requests between last two tags."
                return
            end
            
            if !closed_issues_notes.nil? 
                description += closed_issues_notes
            end

            if !merged_requests_notes.nil? 
                description += merged_requests_notes
            end 
            
            post_new_release(conn, description, tag)
        end

        def generate_merged_requests_notes(conn, merged_requests) 
            if merged_requests.count == 0 
                return nil
            end 
            description = '#### Closed merge requests\r\n'
            for merge in merged_requests
                description += "- #{merge["title"]} " + "[##{merge["reference"]}]" + "(#{merge["web_url"]})"
                description += " ([#{merge["author"]["username"]}]" + "(#{merge["author"]["web_url"]}))" + '\r\n'
            end    

            return description
        end

        def generate_closed_issues_notes(conn, closed_issues) 
            if closed_issues.count == 0 
                return nil
            end 
            description = '#### Closed issues\r\n' 
            for issue in closed_issues
                description += "- #{issue["title"]} " + "[##{issue["iid"]}]" + "(#{issue["web_url"]})"
                description += " ([#{issue["author"]["username"]}]" + "(#{issue["author"]["web_url"]}))" + '\r\n'
            end 
            
            return description
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