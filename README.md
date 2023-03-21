# README

### Services
The app itself runs on a Heroku app dyno  
The database is a Heroku Postgres instance  
Image and File uploads are stored in a GCP cloud storage bucket  

### Local Development
To develop on localhost, you need to generate a certificate/keys:
`openssl req -x509 -sha256 -nodes -newkey rsa:2048 -days 365 -keyout config/local-certs/localhost.key -out config/local-certs/localhost.crt -subj "/CN=localhost"`
And then configure your browser/OS to trust the generated certificate.
This should allow production SAML to work with in the development environment.

### To use under Github CodeSpaces:
- start a new CodeSpaces instance. The install will take several minutes to complete.
- run `rails db:migrate` to fill in the database with empty tables
- run `rails server` to start the server
- under the "Ports" tab, open the port 3001 link

### Hints
Find a deleted record using paper_trail:
```
PaperTrail::Version.where_object(slug: 'deadbeef')
record = PaperTrail::Version.where_object(slug: 'deadbeef').reify
record.save!
```

### ToDo List (Feb 2023):
- Button to export data into a report ✅
- Add created/edited timestamps for petitions ✅
- Update for 2023 General Election ✅
- Workflow to import data from IRDS from web (or from IRDS directly?)
- Admin panel to enable/disable election-related petition signing
- Move more validation into Models

Copyright assigned to the Associated Students of Stanford University, licensed publicly under the GPLv2.