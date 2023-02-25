openssl req -x509 -sha256 -nodes -newkey rsa:2048 -days 365 -keyout config/local-certs/localhost.key -out config/local-certs/localhost.crt -subj "/CN=localhost"
gem install rails
bundle install
sudo apt update
sudo apt install -y postgresql
sudo pg_ctlcluster 12 main start
sudo sh -c 'sudo -u postgres createuser codespace'
sudo sh -c 'sudo -u postgres createdb demo_development'
rails db:migrate