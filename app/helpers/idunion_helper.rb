module IdunionHelper
    include PlantumlHelper
    include DataAccessHelper

    def archive_credential(id)
        @store = Store.find(id)
        if @store.nil?
            return [false, "ID not found"]
        end

        record = JSON.parse(@store.item)

        # Validation ========
        credoffer_id = record["sowlInfo"]["credentialOfferId"].to_s rescue nil
        if credoffer_id.to_s.strip == ""
            return [false, "missing credentialOfferId"]
        end

        # SOWL configuration ===
        tenant_id = ENV["SOWL_TENANT_ID"]
        app_id = ENV["SOWL_VCAPP_ID"]
        app_secret = ENV["SOWL_VCAPP_SECRET"]
        credef_id = ENV["SOWL_VCDEF_ID"]

        # retrieve Token (only valid 60s)
        auth_token = Base64.strict_encode64(app_id + ":" + app_secret)
        token_response = HTTParty.post(SOWL_SERVER_URL + "/api/authentication/authenticateAPIConsumerOIDC", 
            headers: { 'Content-Type' => 'application/json', 'Authorization' => 'Basic ' + auth_token})

        # trigger rule engine
        rule_url = SOWL_SERVER_URL
        rule_url += "/api/data/rule/service"
        rule_url += "?tenant=" + tenant_id
        rule_response = HTTParty.get(rule_url, 
            headers: { 'Content-Type' => 'application/json', 
                       'Authorization' => "Bearer " + token_response.parsed_response["id_token"]})

        # check Status of Credential Offer
        credoffer_url = SOWL_SERVER_URL
        credoffer_url += "/api/data/credentialoffer/" + credoffer_id
        credoffer_url += "?tenant=" + tenant_id
        credoffer_response = HTTParty.get(credoffer_url, 
            headers: { 'Content-Type' => 'application/json', 
                       'Authorization' => "Bearer " + token_response.parsed_response["id_token"]})

        credential_state = credoffer_response.parsed_response["credentialState"].to_s rescue nil
        if credential_state.to_s == "Issued"
            record["sowlInfo"]["certificateAccepted"] = DateTime.now.utc.iso8601
            @store.update(
                item: record.to_json,
                dri: Oydid.hash(Oydid.canonical(record)),
                schema_dri: VC_ARCHIVE_DRI)

            if !record["oydDatavault"].nil?
                datavault_url = record["oydDatavault"]["endpoint"].to_s
                token = record["oydDatavault"]["token"].to_s
                whoCovid19Credential = record["vaccinationCertificate"]
                params = {id: id, p: "id"}
                @pagy, provision = getProvision(params, "read " + params.to_json)
                payload = {
                    id: record["oydDatavault"]["id"],
                    value: whoCovid19Credential,
                    schema_dri: WHO_COVID19CREDENTIAL_DRI,
                    provenance: plantuml(provision)
                }

                retVal = HTTParty.post(datavault_url,
                    headers: { 'Content-Type' => 'application/json' },
                    body: payload.to_json)

            end

            return [true, ""]
        else
            return [false, "wrong state"]
        end

    end

    def archive_request(id)
        @store = Store.find(id)
        if @store.nil?
            return [false, "ID not found"]
        end

        record = JSON.parse(@store.item)

        # Validation ========
        proof_id = record["sowlInfo"]["proofId"].to_s rescue nil
        if proof_id.to_s.strip == ""
            return [false, "missing proofRequestId"]
        end

        # SOWL configuration ===
        tenant_id = ENV["SOWL_TENANT_ID"]
        app_id = ENV["SOWL_VCAPP_ID"]
        app_secret = ENV["SOWL_VCAPP_SECRET"]


        # retrieve Token (only valid 60s)
        auth_token = Base64.strict_encode64(app_id + ":" + app_secret)
        token_response = HTTParty.post(SOWL_SERVER_URL + "/api/authentication/authenticateAPIConsumerOIDC", 
            headers: { 'Content-Type' => 'application/json', 'Authorization' => 'Basic ' + auth_token})

        # trigger rule engine
        rule_url = SOWL_SERVER_URL
        rule_url += "/api/data/rule/service"
        rule_url += "?tenant=" + tenant_id
        rule_response = HTTParty.get(rule_url, 
            headers: { 'Content-Type' => 'application/json', 
                       'Authorization' => "Bearer " + token_response.parsed_response["id_token"]})

        # check Status of Proof Request
        prcheck_url = SOWL_SERVER_URL
        prcheck_url += "/api/data/proofrequest/" + proof_id
        prcheck_url += "?tenant=" + tenant_id
        prcheck_response = HTTParty.get(prcheck_url, 
            headers: { 'Content-Type' => 'application/json', 
                       'Authorization' => "Bearer " + token_response.parsed_response["id_token"]})
puts "Proof Request State: " + prcheck_response.parsed_response["valid"].to_s

        proofRequest_state = prcheck_response.parsed_response["valid"].to_s rescue nil
        if proofRequest_state.to_s == "true"
            record["sowlInfo"]["proofProvided"] = DateTime.now.utc.iso8601
            record["vaccinationProof"]["result"] = true
            record["vaccinationProof"]["proof"] = JSON.parse(prcheck_response.parsed_response["proofJson"])["proof"]
            @store.update(
                item: record.to_json,
                dri: Oydid.hash(Oydid.canonical(record)),
                schema_dri: PROOF_ARCHIVE_DRI)
            return [true, ""]
        else
            return [false, "wrong state"]
        end

    end

end