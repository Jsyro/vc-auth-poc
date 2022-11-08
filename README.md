# vc-auth-poc

This repo is an exercise to connect the vc-authn-oidc project (which has been updated in this repo to use 16.0.0), with an existing project which enable Verifiable Credentials to be used as an Identity Provider to a OIDC platform, and using that to control authentication to a web application.

This demo includes:

1. jboss/keycloak 16.0.0 @ http://localhost:8180
1. [vc-authn-oidc](https://github.com/bcgov/vc-authn-oidc) application @ http://localhost:5001 (tunneled with ngrok)
1. An acapy agent for the vc-authn-oidc project (tunneled with ngrok)
1. [vue-scaffold](https://github.com/bcgov/vue-scaffold) application that has been modified to set and forward a `pres_req_conf_id` to the vc identity provider

Important Configuration notes for each application:

All apps are configured to use the test.bcovrin.vonx.io Sovrin Hyperlegder

1. Keycloak contains

   1. An Identity Provider (IDP) named 'Verifiable Credential Access' **(Service 2)**
      1. A attribute mapper to import the `pres_req_conf_id` to the user (see why below)
   2. A Client named 'vue-fe' **(Service 3)**
      1. A attribute mapper to include the `pres_req_conf_id` in the jwt (see why below)

2. vc-authn-oidc contains.

   1. a Presentation Request Configuration names `test-request-config`
      1. The presentation request is for two values (`first_name`, and `last_name`) with no restrictions. (the demo does not currently include how to obtain this credential)
      1. `subject_identifier` is the claim value that will be used as the KC username and must be key that is in presentation request.
         - If your use case intends to maintain amonyminty (the presentation request will not contain an unique identifier), then ensure that the VC IDP will not import any attribute as the username, and do not set `subject_identifier`.
           - This will mean that keycloak will create a user record every session. There is no mitigation strategy for this bloat yet.

3. The Vue Web app contains.
   1. The `pres_req_conf_id` for the presentation request that the user will be challenged for upon login
      1. `pres_req_conf_id` is appended as query parameter and is not a standard OIDC parameter.
   1. An additional check that the token contains the `pres_req_conf_id` claim and it matches the one within the application.

## Running the demo

### Prerequisites

1. A mobile wallet application with a credential containing at least the attributes `first_name` and `last_name`.

**PROVIDE INSTRUCTIONS on how to issue yourself a credential for the demo**

From this folder

First terminal

```
cd /oidc/demo/scripts
./start-ngrok.sh
```

- Copy the second ngrok address from the output shown as <NGROK_CONTROLLER_URL> in the example below.

`Running in demo mode, will use http://test.bcovrin.vonx.io/genesis to fetch the genesis transaction, <NGROK_AGENT_URL> for the agent and <NGROK_CONTROLLER_URL> for the controller.`

---

Second Terminal

```
./setup-demo.sh
```

---

In a browser navigate to http://localhost:8180

1. login with username `admin` and password `admin`
1. Identity Providers -> 'Verifiable Credential Access'

1. Change the following
   - `Authorization URL` from `**http://localhost:5001**/vc/connect/authorize` -> `<NGROK_CONTROLLER_URL>/vc/connect/authorize`
   - `Token URL` from `http://localhost:5001/vc/connect/token` -> `<NGROK_CONTROLLER_URL>/vc/connect/token`

---

In a browser navigate to http://localhost:8080

1. Click Login
2. Click 'Verifiable Credential Access'
3. Scan QR code with mobile device, and present the credential.

### What happened

1. The application sent you to keycloak so you could login, and included the `pres_req_conf_id`
1. keycloak forwarded you to the vc-authn-oidc application
1. vc-authn-oidc then used that `pres_req_conf_id` to present the QR code to the user with the connectionless presentation exchange with the 'presentation_request' from the 'presentation_request_configuration'
1. vc-authn agent receives the presentation and verifies it and calls the webhook url for the vc-authn controller
1. the vc-authn controller then completes the OIDC identity provider login process
1. the vc-authn-oidc FE is polling the controller and now finds that the presentation has been verified and the login was successful, and redirects the FE back to the vue-scaffold
1. And now we have a OIDC JWT token to use the secured application and it contains the configured claims.

Architechture Roadmap:

1. Replace standalone aca-py agent with a tenant in a Traction installation
2. Add Issuer controller and FE to connect and offer credential
3. Improve administration of the IDP service (by enhancing or replacing the existing vc-authn-oidc project)

![image](https://user-images.githubusercontent.com/5376854/200621504-2136363c-96fb-40cf-875c-11ad0f73f8c8.png)
