module Api
    module V1
        class ProcessesController < ApiController
            require 'securerandom'
            include ApplicationHelper
            include IdunionHelper
            include Pagy::Backend
            include ProvenanceHelper
            include PlantumlHelper

            # respond only to JSON requests
            respond_to :json
            respond_to :html, only: []
            respond_to :xml, only: []

            def active
                retVal = { "active": true,
                           "auth": !(ENV["AUTH"].to_s == "" || ENV["AUTH"].to_s.downcase == "false") ,
                           "repos": false,
                           "watermark":  ENV["WATERMARK"].to_s != "",
                           "billing": ENV["AUTH"].to_s == "billing",
                           "scopes": ["admin", "write", "read"]
                         }
                @store = Store.where(schema_dri: CONFIG_ITEM_DRI) # SOyA Configuration
                @store.each do |i|
                    begin
                        if JSON.parse(i.item)["key"] == "oauth"
                            if retVal["oauth"].nil?
                                retVal["oauth"] = [JSON.parse(JSON.parse(i.item)["value"])]
                            else
                                retVal["oauth"] << JSON.parse(JSON.parse(i.item)["value"])
                            end
                        end
                    rescue
                    end
                end unless @store.nil?
                render json: retVal,
                       status: 200
            end

            def init
                # clean up
                uid = SecureRandom.uuid
                if Semantic.count == 0
                    Semantic.create!(uid: uid)
                end

                request_sh = "run.sh"
                if params[:run].to_s == ""
                    request_sh = "init.sh"
                end

                if !(ENV["AUTH"].to_s == "" || ENV["AUTH"].to_s.downcase == "false")
                    if Doorkeeper::Application.count == 0
                        Doorkeeper::Application.create!({ 
                            name: 'master', 
                            redirect_uri: 'urn:ietf:wg:oauth:2.0:oob',
                            scopes: 'admin write read'})
                    end
                    puts "APP_KEY: " + Doorkeeper::Application.first.uid.to_s
                    puts "APP_SECRET: " + Doorkeeper::Application.first.secret.to_s
                    request_sh += " (with authentication)"
                end

                if ENV["IMAGE_NAME"].to_s == ""
                    scope = uid.to_s
                else
                    scope = ENV["IMAGE_NAME"].to_s + " (" + ENV["IMAGE_SHA256"].to_s + "): " + uid.to_s
                end
                createLog({
                    "type": "create",
                    "scope": scope })

                render plain: "",
                       status: 200

            end

            def scheduler
                schema_dri = params[:schema].to_s rescue nil
                if schema_dri.to_s == ""
                    render json: {"error": "invalid or missing schema_dri"},
                           status: 400
                    return
                end
                @recs = Store.where(schema_dri: schema_dri)
                @recs.each do |rec|
puts "process: " + rec.id.to_s
puts JSON.pretty_generate(JSON.parse(rec.item))
                    success, message = archive_credential(rec.id)
                    success, message = archive_request(rec.id)
puts success.to_s + " - " + message.to_s
puts "---"
                end unless @recs.nil?

                render plain: "",
                       status: 200
            end
        end
    end
end

