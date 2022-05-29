module Api
    module V1
        class DpvsController < ApiController

            # respond only to JSON requests
            respond_to :json
            respond_to :html, only: []
            respond_to :xml, only: []

            def show_usage
                usage_policy = {}
                @configItems = Store.where(schema_dri: CONFIG_ITEM_DRI)
                @configItems.each do |i|
                    begin
                        if JSON.parse(i.item)["key"] == "usage_policy"
                            usage_policy = JSON.parse(JSON.parse(i.item)["value"])
                        end
                    rescue
                    end
                end unless @configItems.nil?
                render json: usage_policy,
                       status: 200
            end
        end
    end
end