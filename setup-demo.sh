cp ./custom-vcauthn-realm.json oidc/docker/keycloak/config/custom-vcauthn-realm.json
(cd oidc/docker && ./manage build)
(cd oidc/docker && GENESIS_URL="http://test.bcovrin.vonx.io/genesis" KEYCLOAK_IMPORT="/tmp/custom-vcauthn-realm.json" ./manage start-demo)



# name of pres-req
export PRES_REQ_CONF_ID="test-request-config"

# wait for vc-authn idp to start up
sleep 15
# Add pres_req_conf to project
curl --connect-timeout 5 \
     --retry-all-errors \
     --max-time 10 \
     --retry 5 \
     --retry-delay 0 \
     -X POST "http://localhost:5001/api/vc-configs" \
     -H "accept: application/json" \
     -H "X-Api-Key: controller-api-key" \
     -H "Content-Type: application/json-patch+json" \
     -d "{ \"id\": \"$PRES_REQ_CONF_ID\", \"subject_identifier\": \"first_name\", \"configuration\": { \"name\": \"Basic Proof\", \"version\": \"1.0\", \"requested_attributes\": [ { \"name\": \"first_name\", \"restrictions\": [] }, { \"name\": \"last_name\", \"restrictions\": [] } ], \"requested_predicates\": [] }}"




# Start vue app with PRES_REQ_CONF_ID added
PRES_REQ_CONF_ID="${PRES_REQ_CONF_ID}" docker-compose -f ./vue/docker-compose.yaml up --build -d

# curl -X POST "http://localhost:5678/issue-credential/create-offer" \
#      -H "Content-Type: application/json-patch+json" \
#      -d {
#   "auto_issue": "true",
#   "auto_remove": "false",
#   "comment": "issue-test-cred",
#   "cred_def_id": "WgWxqztrNooG92RXvxSTWv:3:CL:20:tag",
#   "credential_preview": {
#     "@type": "issue-credential/1.0/credential-preview",
#     "attributes": [
#       {
#         "name": "email",
#         "value": "test@auth.com"
#       },
#             {
#         "name": "first_name",
#         "value": "fname"
#       },
#             {
#         "name": "last_name",
#         "value": "lname"
#       }
#     ]
#   },
#   "trace": true
# }

# curl -X POST "http://localhost:5678/credential-definitions" \
#      -H "Content-Type: application/json-patch+json" \
# {
#   "schema_id": "WgWxqztrNooG92RXvxSTWv:2:schema_name:1.0",
#   "support_revocation": false,
#   "tag": "default"
# }

# qrencode -t ASCII -o 


### after running this 
# 1 Update urls in VC IDP with the ones provided by NGROK
# 2 Go to http://localhost:8180, then 
# 2a 'Authentication' and change the 'First Broker Login' 'Review Profile' step to 'Disabled'
# 2b Go to Realm Settings > Login, change Login with email to 'Off' and set 'Duplicate Emails' to 'On'
# 2c Go to 'Identity Providers' > 'Mappers' > 'Create'
#    name it something like VC_id
#    Type = 'Attribute Importer'
#    Claim = 'first_name'
#    'Claim' is the value in the Configured Presenation Request you want to act as the user's id
#    'User Attribute Name' = 'username'
#    'User Attribute Name' is the KEY of the keycloak attribute you wish to bind the claim to


#NOTES!!!!
# Need KC username to be CONNECTION ID, conn id is cached and given to controller, which prompts user phone
# if no conn_id, then invite to connection
# login with same conn_id get's mapped to same user
# login with different conn_id but same username causes the correct errro, as username should be mapped to a globally unique id



  #sed -i "s/http://'localhost:5001'/'${NGROK_CONTROLLER_URL}'/g" ${KEYCLOAK_IMPORT}
