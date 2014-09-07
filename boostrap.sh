#!/usr/bin/env bash

FQDN=localhost

ELASTICSEARCH_VERSION=1.1.1
KIBANA_VERSION=3.0.1
LOGSTASH_VERSION=1.4.2

# Add Repo for Oracle Java 7
#sudo add-apt-repository -y ppa:webupd8team/java
#sudo apt-get update
#sudo apt-get -y install oracle-java7-installer

# Add repo for elasticsearch and logstash
echo "Adding external repositories..."
curl -s http://packages.elasticsearch.org/GPG-KEY-elasticsearch | sudo apt-key add -
echo "deb http://packages.elasticsearch.org/elasticsearch/${ELASTICSEARCH_VERSION%.*}/debian stable main" | sudo tee /etc/apt/sources.list.d/elasticsearch.list
echo "deb http://packages.elasticsearch.org/logstash/${LOGSTASH_VERSION%.*}/debian stable main" | sudo tee /etc/apt/sources.list.d/logstash.list

# Install nginx, openjdk-java, elasticsearch, logstash
echo "Installing nginx, openjdk, elasticsearch, logstash..."
sudo apt-get update
sudo apt-get autoremove
sudo apt-get -y install nginx openjdk-7-jre-headless elasticsearch=${ELASTICSEARCH_VERSION} logstash=${LOGSTASH_VERSION}-*

# Configure ElasticSearch
echo "Configuring ElasticSearch..."
echo "script.disable_dynamic: true" | sudo tee --append /etc/elasticsearch/elasticsearch.yml > /dev/null
echo "network.host: localhost" | sudo tee --append /etc/elasticsearch/elasticsearch.yml > /dev/null
sudo service elasticsearch restart
sudo update-rc.d elasticsearch defaults 95 10

# Install Kibana
echo "Installing Kibana"
curl -s -o /tmp/kibana.tar.gz https://download.elasticsearch.org/kibana/kibana/kibana-${KIBANA_VERSION}.tar.gz
sudo mkdir -p /var/www/kibana3
sudo tar xvzf /tmp/kibana.tar.gz -C /var/www/kibana3 --strip 1
sudo sed -i 's/\(^\s*elasticsearch.*\)9200/\180/g' /var/www/kibana3/config.js
curl -s -o /tmp/kibana.conf https://raw.githubusercontent.com/elasticsearch/kibana/master/sample/nginx.conf
sed -i "s/kibana.myhost.org/${FQDN}/g;s/^\(\s*root\s*\).*;/\1\/var\/www\/kibana3;/g;s/^\(\s*auth_basic.*\)/#\1/g;" /tmp/kibana.conf
sudo cp /tmp/kibana.conf /etc/nginx/sites-available/kibana.conf
sudo rm /etc/nginx/sites-enabled/default
sudo ln -s /etc/nginx/sites-available/kibana.conf /etc/nginx/sites-enabled/.
sudo service nginx restart

# Configure Logstash
echo "Configuring Logstash..."
sudo cp /vagrant/logstash_conf/* /etc/logstash/conf.d/.
sudo service logstash restart

# Generate server certificates
sudo mkdir -p /etc/pki/tls/certs
sudo mkdir /etc/pki/tls/private
sudo openssl req -x509 -batch -nodes -days 3650 -newkey rsa:2048 -keyout /etc/pki/tls/private/logstash-forwarder.key -out /etc/pki/tls/certs/logstash-forwarder.crt 2>/dev/null

# install prerequisite packages
#echo "Installing packages..."
#apt-get -y install redis-server rabbitmq-server g++ git make

