module Api
    module V1
        class VerifiersController < ApiController
            include IdunionHelper

            # respond only to JSON requests
            respond_to :json
            respond_to :html, only: []
            respond_to :xml, only: []

            def new
                proof_template = {}
                @template = Store.find_by_schema_dri(PROOF_TEMPLATE_DRI)
                if !@template.nil?
                    proof_template = JSON.parse(@template.item) rescue {}
                end
                @store = Store.new(
                    item: proof_template.to_json,
                    dri: Oydid.hash(Oydid.canonical(proof_template)),
                    schema_dri: PROOF_APPLY_DRI
                    )
                @store.save
                render json: {id: @store.id}, 
                       status: 200
            end

            def update
                id = params[:id]
                @store = Store.find(id)
                record = JSON.parse(@store.item)

                # Validation ========
                person_name = record["vaccinationProof"]["header"]["name"].to_s rescue nil
                sowl_user = record["sowlInfo"]["userEmail"].to_s rescue nil
                if person_name.to_s.strip == "" ||
                        sowl_user.to_s.strip == ""
                    render json: {}, 
                           status: 200
                    return
                end

                # SOWL configuration ===
                tenant_id = ENV["SOWL_TENANT_ID"]
                app_id = ENV["SOWL_VCAPP_ID"]
                app_secret = ENV["SOWL_VCAPP_SECRET"]
                proof_id = ENV["SOWL_PRFTMPL_ID"]

                # retrieve Token (only valid 60s)
                auth_token = Base64.strict_encode64(app_id + ":" + app_secret)
                token_response = HTTParty.post(SOWL_SERVER_URL + "/api/authentication/authenticateAPIConsumerOIDC", 
                    headers: { 'Content-Type' => 'application/json', 'Authorization' => 'Basic ' + auth_token})

                # retrieve identity
                all_users = HTTParty.get(SOWL_SERVER_URL + "/api/data/identity?tenant=" + tenant_id, 
                                    headers: { 'Content-Type' => 'application/json', 'Authorization' => "Bearer " + token_response.parsed_response["id_token"]})
                identity = nil
                all_users.parsed_response.each do |user|
                    if user["email"] == sowl_user
                        identity = user["id"]
                        break
                    end
                end

                # request proof
                pr_url = SOWL_SERVER_URL
                pr_url += "/api/proofrequest"
                pr_url += "?tenant=" + tenant_id
                pr_url += "&identityID=" + identity.to_s
                # pr_url += "&creator=" + verifier_identity
                pr_url += "&name=" + Time.now.to_i.to_s
                pr_url += "&proofTemplateID=" + proof_id
                pr_response = HTTParty.post(pr_url,
                    headers: { 'Content-Type' => 'application/json', 
                               'Authorization' => "Bearer " + token_response.parsed_response["id_token"]})
                proof_id = pr_response.parsed_response["id"].to_s

                record["sowlInfo"]["proofRequested"] = DateTime.now.utc.iso8601
                record["sowlInfo"]["proofId"] = proof_id.to_s

                @store.update_attributes(
                    item: record.to_json,
                    dri: Oydid.hash(Oydid.canonical(record)),
                    schema_dri: PROOF_ISSUED_DRI)

                render json: {}, 
                       status: 200
            end

            def check
                id = params[:id]
                success, message = archive_request(id)
                if success
                    render plain: "", 
                           status: 200
                else
                    render json: {"error": message},
                           status: 200
                end

            end
        end
    end
end