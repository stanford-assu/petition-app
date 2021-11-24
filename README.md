# README

### Local Development
To develop on localhost, you need to generate a certifcate/keys:
`openssl req -x509 -sha256 -nodes -newkey rsa:2048 -days 365 -keyout config/local-certs/localhost.key -out config/local-certs/localhost.crt -subj "/CN=localhost"`
And then configure your browser/OS to trust the generated certificate.
This should allow production SAML to work with in the development environment.
