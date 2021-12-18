# README

### Services
The app itself runs on a Heroku app dyno
The database is a Heroku Postgres instance
Image and File uploads are stored in a GCP cloud storage bucket

### Local Development
To develop on localhost, you need to generate a certifcate/keys:
`openssl req -x509 -sha256 -nodes -newkey rsa:2048 -days 365 -keyout config/local-certs/localhost.key -out config/local-certs/localhost.crt -subj "/CN=localhost"`
And then configure your browser/OS to trust the generated certificate.
This should allow production SAML to work with in the development environment.

### Things that still need to be done:
- Bulk import of grad/undergrad status
- Do we want to restict who can sign what type of petition?
- Should there be different types of petitions?

