ls
oydid
vi 
vi issuer_did.json
cat issuer_did.json | oydid create
oydid read zQmeXf2hUQgW83vAuMTqJwrafHr9111TEk6MQj4L7zK8E2r
oydid read --w3c-did zQmeXf2hUQgW83vAuMTqJwrafHr9111TEk6MQj4L7zK8E2r
oydid read --w3c-did zQmeXf2hUQgW83vAuMTqJwrafHr9111TEk6MQj4L7zK8E2r | jq
exit
oydid read
oydid read zQmYmScpCsSLnZP3bF3h4RnvDzJqSvQcG3zCGR8xbcZshnQ
echo '{"usagePolicy":"https://idunion-issuer.data-container.net/api/meta/usage","info":"https://idunion-issuer.data-container.net/api/vaccination_info","connect":"https://idunion-issuer.data-container.net/api/vaccination_apply","schemaDri":"zQmXv24pytvtcfC72NVY5AjhJtg25kyV8N7FK6KmuijhuxN"}' | oydid update zQmYmScpCsSLnZP3bF3h4RnvDzJqSvQcG3zCGR8xbcZshnQ
oydid read did:oyd:zQmYmScpCsSLnZP3bF3h4RnvDzJqSvQcG3zCGR8xbcZshnQ 
echo '{"usagePolicy":"https://idunion-issuer.data-container.net/api/meta/usage","info":"https://idunion-issuer.data-container.net/api/vaccination_info","connect":"https://idunion-issuer.data-container.net/api/vaccination_apply","schemaDri":"zQmWV6CtFhQE4Ybeo8XvSwiyjLDJ9G99NbVpCVUCgtqpF5h"}' | oydid update zQmdi3xp5hMLJ6yyL8v7Q3eDqSysRZjhpRdRewaF5WiLEm3
oydid read did:oyd:zQmYmScpCsSLnZP3bF3h4RnvDzJqSvQcG3zCGR8xbcZshnQ 
exit
echo '{"usagePolicy":"https://idunion-issuer.data-container.net/api/meta/usage","info":"https://idunion-issuer.data-container.net/api/vaccination_info","connect":"https://idunion-issuer.data-container.net/api/vaccination_apply","schemaDri":"zQmXfghr3YmpnoKjXJ11Xs9dqG7GN3DNhD86oEr4wGxNZUm"}' | oydid update zQmeS13c2zGPfFaiYdmwFq82knqY3prSbQJXA7AkgNp4tRz
echo '{"usagePolicy":"https://idunion-issuer.data-container.net/api/meta/usage","info":"https://idunion-issuer.data-container.net/api/vaccination_info","connect":"https://idunion-issuer.data-container.net/api/vaccination_apply","schemaDri":"zQma9Trg5MQTkmcm3ZWxRZ7ZhckSbtEGxLexkrWqq87PtY6"}' | oydid update zQmcPwhhpj2K8KRAVQuQiQ39tCXXEy8uDzChyYm5HJzwxgQ
exit
ls
oydid read did:oyd:zQmTKdtV2beKbJxTjWLdBqVe8UY1ddms7xSLq4ePHC2uNuc
oydid read did:oyd:zQmTKdtV2beKbJxTjWLdBqVe8UY1ddms7xSLq4ePHC2uNuc | jq
curl
curl https://idunion-verifier.data-container.net/api/meta/usage
echo '{
    "usagePolicy": "https://idunion-verifier.data-container.net/api/meta/usage",
    "info": "https://idunion-verifier.data-container.net/api/verifier_info",
    "connect": "https://idunion-verifier.data-container.net/api/request_access"
}' | jq -c
echo '{
    "usagePolicy": "https://idunion-verifier.data-container.net/api/meta/usage",
    "info": "https://idunion-verifier.data-container.net/api/verifier_info",
    "connect": "https://idunion-verifier.data-container.net/api/request_access"
}' | jq -c | oydid create
exit
ls
echo '[{"id"=>"SharingInfo", "type"=>"AgentService", "serviceEndpoint"=>{"@type"=>"UserServiceEndpoint", "instance"=>["https://idunion-org.data-container.net/api/survey_infos"]}},
{"id"=>"SharingPool", "type"=>"AgentService", "serviceEndpoint"=>{"@type"=>"UserServiceEndpoint", "instance"=>["https://idunion-org.data-container.net/api/data"]}},
{"id"=>"UsagePolicy", "type"=>"AgentService", "serviceEndpoint"=>{"@type"=>"UserServiceEndpoint", "instance"=>["https://idunion-org.data-container.net/api/meta/usage"]}}]' | jq
echo '[{"id"=>"SharingInfo", "type"=>"AgentService", "serviceEndpoint"=>{"@type"=>"UserServiceEndpoint", "instance"=>["https://idunion-org.data-container.net/api/survey_infos"]}},
{"id"=>"SharingPool", "type"=>"AgentService", "serviceEndpoint"=>{"@type"=>"UserServiceEndpoint", "instance"=>["https://idunion-org.data-container.net/api/data"}},
{"id"=>"UsagePolicy", "type"=>"AgentService", "serviceEndpoint"=>{"@type"=>"UserServiceEndpoint", "instance"=>["https://idunion-org.data-container.net/api/meta/usage"}}]'
echo '[{"id"=>"SharingInfo", "type"=>"AgentService", "serviceEndpoint"=>{"@type"=>"UserServiceEndpoint", "instance"=>["https://idunion-org.data-container.net/api/survey_infos"]}},
{"id"=>"SharingPool", "type"=>"AgentService", "serviceEndpoint"=>{"@type"=>"UserServiceEndpoint", "instance"=>["https://idunion-org.data-container.net/api/data"}},
{"id"=>"UsagePolicy", "type"=>"AgentService", "serviceEndpoint"=>{"@type"=>"UserServiceEndpoint", "instance"=>["https://idunion-org.data-container.net/api/meta/usage"}}]' | jq -c
echo '[{"id": "SharingInfo", "type": "AgentService", "serviceEndpoint": {"@type": "UserServiceEndpoint", "instance": ["https://idunion-org.data-container.net/api/survey_infos"]}},
{"id": "SharingPool", "type": "AgentService", "serviceEndpoint": {"@type": "UserServiceEndpoint", "instance": ["https://idunion-org.data-container.net/api/data"]}},
{"id": "UsagePolicy", "type": "AgentService", "serviceEndpoint": {"@type": "UserServiceEndpoint", "instance": ["https://idunion-org.data-container.net/api/meta/usage"]}}]' | jq -c
echo '[{"id": "SharingInfo", "type": "AgentService", "serviceEndpoint": {"@type": "UserServiceEndpoint", "instance": ["https://idunion-org.data-container.net/api/survey_infos"]}},
{"id": "SharingPool", "type": "AgentService", "serviceEndpoint": {"@type": "UserServiceEndpoint", "instance": ["https://idunion-org.data-container.net/api/data"]}},
{"id": "UsagePolicy", "type": "AgentService", "serviceEndpoint": {"@type": "UserServiceEndpoint", "instance": ["https://idunion-org.data-container.net/api/meta/usage"]}}]' | jq -c | oydid create
echo '[{"id": "SharingInfo", "type": "AgentService", "serviceEndpoint": {"@type": "UserServiceEndpoint", "instance": ["https://idunion-org.data-container.net/api/survey_infos"]}},
{"id": "SharingPool", "type": "AgentService", "serviceEndpoint": {"@type": "UserServiceEndpoint", "instance": ["https://idunion-org.data-container.net/api/data"]}},
{"id": "UsagePolicy", "type": "AgentService", "serviceEndpoint": {"@type": "UserServiceEndpoint", "instance": ["https://idunion-org.data-container.net/api/meta/usage"]}}]' | jq
oydid read --w3c-did did:oyd:zQmewaHzjdxEPy5JCirGkqXj9gkHqxdFamX3ybYsULNnL12 | jq 
exit
