module Api
    module V1
        class IssuersController < ApiController
            include IdunionHelper

            # respond only to JSON requests
            respond_to :json
            respond_to :html, only: []
            respond_to :xml, only: []

            def new
                vac_template = {}
                @template = Store.find_by_schema_dri(VC_TEMPLATE_DRI)
                if !@template.nil?
                    vac_template = JSON.parse(@template.item) rescue {}
                end

                @store = Store.new(
                    item: vac_template.to_json,
                    dri: Oydid.hash(Oydid.canonical(vac_template)),
                    schema_dri: VC_APPLY_DRI
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
                person_name = record["vaccinationCertificate"]["header"]["name"].to_s rescue nil
                sowl_user = record["sowlInfo"]["userEmail"].to_s rescue nil
                if person_name.to_s.strip == "" ||
                        sowl_user.to_s.strip == ""
                    render json: {}, 
                           status: 200
                    return
                end
                certificateValidFrom = record["vaccinationCertificate"]["certificateValidFrom"].to_s rescue nil
                if certificateValidFrom.to_s.strip == ""
                    record["vaccinationCertificate"]["certificateValidFrom"] = record["vaccinationCertificate"]["vaccinationEvent"]["validFrom"].to_s rescue ""
                end
                certificateValidUntil = record["vaccinationCertificate"]["certificateValidUntil"].to_s rescue nil
                if certificateValidUntil.to_s.strip == ""
                    record["vaccinationCertificate"]["certificateValidUntil"] = record["vaccinationCertificate"]["vaccinationEvent"]["nextDoseDue"].to_s rescue ""
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

                # issue Credential Offer
                cred_url = SOWL_SERVER_URL
                cred_url += "/api/data"
                cred_url += "/credential/" + credef_id
                cred_url += "/issue/" + identity.to_s
                cred_url += "/0?tenant=" + tenant_id

                vaccinationCertificateMetadata_healthCertificateIdentifier = 
                    record["vaccinationCertificate"]["hcid"]["id"].to_s rescue ""
                vaccinationEvent_dateOfVaccination = 
                    record["vaccinationCertificate"]["vaccinationEvent"]["dateOfVaccination"].to_s rescue ""
                vaccinationCertificateMetadata_certificateSchemaVersion =
                    record["vaccinationCertificate"]["certificateSchemaVersion"].to_s rescue ""
                vaccinationEvent_vaccine =
                    record["vaccinationCertificate"]["vaccinationEvent"]["vaccineOrProphylaxis"].to_s rescue ""
                vaccinationEvent_vaccineBatch =
                    record["vaccinationCertificate"]["vaccinationEvent"]["vaccineBatchNumber"].to_s rescue ""
                vaccinationEvent_manufacture =
                    record["vaccinationCertificate"]["vaccinationEvent"]["vaccineManufacture"].to_s rescue ""
                vaccinationEvent_healthWorkerSignature =
                    record["vaccinationCertificate"]["vaccinationEvent"]["healthWorkerSignature"].to_s rescue ""
                vaccinationCertificateMetadata_certificateIssuer =
                    record["vaccinationCertificate"]["certificateIssuer"].to_s rescue ""
                vaccinationEvent_nextDoseDue =
                    record["vaccinationCertificate"]["vaccinationEvent"]["nextDoseDue"].to_s rescue ""
                vaccinationEvent_marketAuthorization =
                    record["vaccinationCertificate"]["vaccinationEvent"]["vaccineMarketAuthorization"].to_s rescue ""
                vaccinationEvent_countryOfVaccination =
                    record["vaccinationCertificate"]["vaccinationEvent"]["countryOfVaccination"].to_s rescue ""
                vaccinationEvent_doseNumber =
                    record["vaccinationCertificate"]["vaccinationEvent"]["doseNumber"].to_s rescue ""
                vaccinationCertificateMetadata_certificateValidUntil =
                    record["vaccinationCertificate"]["certificateValidUntil"].to_s rescue ""
                vaccinationEvent_diseaseTarget =
                    record["vaccinationCertificate"]["vaccinationEvent"]["diseaseTarget"].to_s rescue ""
                person_sex =
                    record["vaccinationCertificate"]["header"]["sex"].to_s rescue ""
                person_dateOfBirth =
                    record["vaccinationCertificate"]["header"]["dateOfBirth"].to_s rescue ""
                vaccinationEvent_healthWorkerIdentifier =
                    record["vaccinationCertificate"]["vaccinationEvent"]["healthWorkerIdentifier"]["id"].to_s rescue ""
                vaccinationEvent_validFrom =
                    record["vaccinationCertificate"]["vaccinationEvent"]["validFrom"].to_s rescue ""
                vaccinationCertificateMetadata_certificateValidFrom =
                    record["vaccinationCertificate"]["certificateValidFrom"].to_s rescue ""
                person_uniqueIdentifier =
                    record["vaccinationCertificate"]["header"]["uniqueIdentifier"]["id"].to_s rescue ""
                vaccinationEvent_doseTotal =
                    record["vaccinationCertificate"]["vaccinationEvent"]["totalDoses"].to_s rescue ""
                vaccinationEvent_brand =
                    record["vaccinationCertificate"]["vaccinationEvent"]["vaccineBrand"].to_s rescue ""

                cred_object = [ {"encoded": "", "name": "VaccinationCertificateMetadata_healthCertificateIdentifier", 
                                    "value": vaccinationCertificateMetadata_healthCertificateIdentifier },
                                {"encoded": "", "name": "VaccinationEvent_dateOfVaccination", 
                                    "value": vaccinationEvent_dateOfVaccination },
                                {"encoded": "", "name": "VaccinationCertificateMetadata_certificateSchemaVersion", 
                                    "value": vaccinationCertificateMetadata_certificateSchemaVersion },
                                {"encoded": "", "name": "VaccinationEvent_vaccine", 
                                    "value": vaccinationEvent_vaccine },
                                {"encoded": "", "name": "VaccinationEvent_vaccineBatch", 
                                    "value": vaccinationEvent_vaccineBatch },
                                {"encoded": "", "name": "VaccinationEvent_manufacture", 
                                    "value": vaccinationEvent_manufacture },
                                {"encoded": "", "name": "VaccinationEvent_healthWorkerSignature", 
                                    "value": vaccinationEvent_healthWorkerSignature },
                                {"encoded": "", "name": "VaccinationCertificateMetadata_certificateIssuer", 
                                    "value": vaccinationCertificateMetadata_certificateIssuer },
                                {"encoded": "", "name": "VaccinationEvent_nextDoseDue", 
                                    "value": vaccinationEvent_nextDoseDue },
                                {"encoded": "", "name": "VaccinationEvent_marketAuthorization", 
                                    "value": vaccinationEvent_marketAuthorization },
                                {"encoded": "", "name": "VaccinationEvent_countryOfVaccination", 
                                    "value": vaccinationEvent_countryOfVaccination },
                                {"encoded": "", "name": "VaccinationEvent_doseNumber", 
                                    "value": vaccinationEvent_doseNumber },
                                {"encoded": "", "name": "VaccinationCertificateMetadata_certificateValidUntil", 
                                    "value": vaccinationCertificateMetadata_certificateValidUntil },
                                {"encoded": "", "name": "VaccinationEvent_diseaseTarget", 
                                    "value": vaccinationEvent_diseaseTarget },
                                {"encoded": "", "name": "Person_name", 
                                    "value": person_name },
                                {"encoded": "", "name": "Person_sex", 
                                    "value": person_sex },
                                {"encoded": "", "name": "Person_dateOfBirth", 
                                    "value": person_dateOfBirth },
                                {"encoded": "", "name": "VaccinationEvent_healthWorkerIdentifier", 
                                    "value": vaccinationEvent_healthWorkerIdentifier },
                                {"encoded": "", "name": "VaccinationEvent_validFrom", 
                                    "value": vaccinationEvent_validFrom },
                                {"encoded": "", "name": "VaccinationCertificateMetadata_certificateValidFrom", 
                                    "value": vaccinationCertificateMetadata_certificateValidFrom },
                                {"encoded": "", "name": "Person_uniqueIdentifier", 
                                    "value": person_uniqueIdentifier },
                                {"encoded": "", "name": "VaccinationEvent_doseTotal", 
                                    "value": vaccinationEvent_doseTotal },
                                {"encoded": "", "name": "VaccinationEvent_brand", 
                                    "value": vaccinationEvent_brand } ]

                cred_response = HTTParty.post(cred_url, 
                    headers: { 'Content-Type' => 'application/json', 
                               'Accept' => 'application/json',
                               'Authorization' => "Bearer " + token_response.parsed_response["id_token"]},
                    body: cred_object.to_json)
                credoffer_id = cred_response.parsed_response["id"]

                record["sowlInfo"]["certificateIssued"] = DateTime.now.utc.iso8601
                record["sowlInfo"]["credentialOfferId"] = credoffer_id.to_s

                @store.update_attributes(
                    item: record.to_json,
                    dri: Oydid.hash(Oydid.canonical(record)),
                    schema_dri: VC_ISSUED_DRI)

                # check Status of Credential Offer
                credoffer_id = "49410"
                credoffer_url = SOWL_SERVER_URL
                credoffer_url += "/api/data/credentialoffer/" + credoffer_id
                credoffer_url += "?tenant=" + tenant_id
                credoffer_response = HTTParty.get(credoffer_url, 
                    headers: { 'Content-Type' => 'application/json', 
                               'Authorization' => "Bearer " + token_response.parsed_response["id_token"]})

                render json: {}, 
                       status: 200
            end

            def check
                id = params[:id]
                success, message = archive_credential(id)
                if success
                    render plain: "", 
                           status: 200
                else
                    render json: {"error": message},
                           status: 200
                end

            end

            def vaccination_info
                vaccination_info = {}
                @configItems = Store.where(schema_dri: CONFIG_ITEM_DRI)
                @configItems.each do |i|
                    begin
                        if JSON.parse(i.item)["key"] == "vaccination_info"
                            vaccination_info = JSON.parse(JSON.parse(i.item)["value"])
                        end
                    rescue
                    end
                end unless @configItems.nil?
                render json: vaccination_info,
                       status: 200

            end

            def vaccination_apply
                vac_template = {}
                @template = Store.find_by_schema_dri(VC_TEMPLATE_DRI)
                if !@template.nil?
                    vac_template = JSON.parse(@template.item) rescue {}
                end

                # Name
                person_name = params["issuer"]["name"].to_s
                if vac_template["vaccinationCertificate"].nil?
                    vac_template["vaccinationCertificate"] = {}
                end
                if vac_template["vaccinationCertificate"]["header"].nil?
                    vac_template["vaccinationCertificate"]["header"] = {}
                end
                vac_template["vaccinationCertificate"]["header"]["name"] = person_name

                # Date of Birth
                dob = params["issuer"]["dateOfBirth"].to_s
                vac_template["vaccinationCertificate"]["header"]["dateOfBirth"] = dob

                # Sex
                sex = params["issuer"]["sex"].to_s
                vac_template["vaccinationCertificate"]["header"]["sex"] = sex

                # SVNr
                svnr = params["issuer"]["svnr"].to_s
                if vac_template["vaccinationCertificate"]["header"]["uniqueIdentifier"].nil?
                    vac_template["vaccinationCertificate"]["header"]["uniqueIdentifier"] = {}
                end
                vac_template["vaccinationCertificate"]["header"]["uniqueIdentifier"]["id"] = svnr

                # Email
                sowl_email = params["issuer"]["userEmail"].to_s
                if vac_template["sowlInfo"].nil?
                    vac_template["sowlInfo"] = {}
                end
                vac_template["sowlInfo"]["userEmail"] = sowl_email

                # OYD Data Vault information
                if vac_template["oydDatavault"].nil?
                    vac_template["oydDatavault"] = {}
                end
                vac_template["oydDatavault"]["endpoint"] = params["issuer"]["oydDatavault"].to_s
                vac_template["oydDatavault"]["token"] = params["issuer"]["oydToken"].to_s
                vac_template["oydDatavault"]["id"] = params["issuer"]["oydId"].to_s

                @store = Store.new(
                    item: vac_template.to_json,
                    dri: Oydid.hash(Oydid.canonical(vac_template)),
                    schema_dri: VC_APPLY_DRI )
                @store.save

                render json: {},
                       status: 200
            end
        end
    end
end