# vc-auth-poc

This repo is an exercise to connect the vc-authn-oidc project (which has been updated in this repo to use 16.0.0).

This demo includes:

1. jboss/keycloak 16.0.0 @ http://localhost:8180
1. vc-authn-oidc application @ http://localhost:5001 (tunneled with ngrok)
1. An acapy agent for the vc-authn-oidc project (tunneled with ngrok)
1. vue-scaffold-template application that has been modified to set and forward a `pres_req_conf_id` to the vc identity provider

Important Configuration notes for each application:

All apps are configured to use the test.bcovrin.vonx.io Sovrin Hyperlegder

1. Keycloak contains

   1. An Identity Provider (IDP) named 'Verifiable Credential Access' **(Service 2)**
      1. A attribute mapper to import the `pres_req_conf_id` to the user (see why below)
   2. A Client named 'vue-fe' **(Service 3)**
      1. A attribute mapper to include the `pres_req_conf_id` in the jwt (see why below)

2. vc-authn-oidc contains.

   1. a Presentation Request Configuration names `test-request-config`
      1. The presentation request is for two values (`first_name`, and `last_name`) with no restrictions. (see demo walkthrough for how to obtain this credential)
      1. `subject_identifier` is the claim value that will be used as the KC username and must be key that is in presentation request.
         - If your use case intends to maintain amonyminty (the presentation request will not contain an unique identifier), then ensure that the VC IDP will not import any attribute as the username, and do not set `subject_identifier`.
           - This will mean that keycloak will create a user record every session. There is no mitigation strategy for this bloat yet.

3. The Vue Web app contains.
   1. The `pres_req_conf_id` for the presentation request that the user will be challenged for upon login
      1. `pres_req_conf_id` is appended as query parameter and is not a standard OIDC parameter.
   1. An additional check that the token contains the `pres_req_conf_id` claim and it matches the one within the application.

## Running the demo

From this folder

First terminal

```
cd /oidc/demo/scripts
./start-ngrok.sh
```

- Copy the second ngrok address from the output.

'Running in demo mode, will use http://test.bcovrin.vonx.io/genesis to fetch the genesis transaction, <NGROK_AGENT_URL> for the agent and <NGROK_CONTROLLER_URL> for the controller.'

Second Terminal

```
./setup-demo.sh
```

navigate to http://localhost:8180
