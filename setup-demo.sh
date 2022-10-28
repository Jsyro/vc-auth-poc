cp ./custom-vcauthn-realm.json oidc/docker/keycloak/config/custom-vcauthn-realm.json
(cd oidc/docker && GENESIS_URL="http://test.bcovrin.vonx.io/genesis" KEYCLOAK_IMPORT="/tmp/custom-vcauthn-realm.json" ./manage up-bg)

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
     -d "{ \"id\": \"$PRES_REQ_CONF_ID\", \"subject_identifier\": \"email\", \"configuration\": { \"name\": \"Basic Proof\", \"version\": \"1.0\", \"requested_attributes\": [ { \"name\": \"email\", \"restrictions\": [] }, { \"name\": \"first_name\", \"restrictions\": [] }, { \"name\": \"last_name\", \"restrictions\": [] } ], \"requested_predicates\": [] }}"


# Start vue app with PRES_REQ_CONF_ID added
PRES_REQ_CONF_ID="${PRES_REQ_CONF_ID}" docker-compose -f ./vue/docker-compose.yaml up -d