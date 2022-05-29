class ApiController < ApplicationController
    before_action :authentication_check

    private

    def authentication_check
        require 'uri'
        if !(ENV["AUTH"].to_s == "" || ENV["AUTH"].to_s.downcase == "false")
            if action_name != "active" && 
                    action_name != "show_usage" && 
                    action_name != "vaccination_info" && 
                    action_name != "vaccination_apply" &&
                    action_name != "init" && 
                    !(controller_name == "receipts" && (action_name == "show" || action_name == "revoke"))
                @oauth = Doorkeeper::Application.find(doorkeeper_token.application_id) rescue nil
                if @oauth.nil?
                    render json: {"error": "unauthorized request (OAuth app not found)"},
                           status: 403
                else
                    if action_name == "write"
                        doorkeeper_authorize! :write, :admin
                    else
                        doorkeeper_authorize! :read, :admin  # was:  :read, :write, :admin
                    end
                    if !@oauth.sc_query.nil?
                        uri = URI(request.url.to_s)
                        if uri.query.to_s == ""
                            q = uri.path
                        else
                            q = uri.path + "?" + uri.query
                        end
                        if q.to_s != @oauth.sc_query.to_s
                            render json: {"error": "unauthorized request (invalid query)"},
                                   status: 403
                        end
                        # puts "Request URL: " + request.url.to_s
                        # puts "query: " + q.to_s
                        # puts "sc_query: " + @oauth.sc_query.to_s
                        # puts "match: " + (q.to_s == @oauth.sc_query.to_s).to_s
                    end
                end
            end
        end
    end
end
