#!/bin/sh
set -e 
echo "https://alpine.ykode.com/alpine/v3.5/main" > /etc/apk/repositories
echo "https://alpine.ykode.com/alpine/v3.5/community" >> /etc/apk/repositories

apk add --update jq unzip curl 

echo "Determining Consul Version to Install..."
CHECKPOINT_URL="https://checkpoint-api.hashicorp.com/v1/check"
if [ -z "$CONSUL_DEMO_VERSION" ]; then
    CONSUL_DEMO_VERSION=$(curl -s "${CHECKPOINT_URL}"/consul | jq .current_version | tr -d '"')
fi

echo "Fetching Consul version ${CONSUL_DEMO_VERSION} ..."
cd /tmp/
curl -s https://releases.hashicorp.com/consul/${CONSUL_DEMO_VERSION}/consul_${CONSUL_DEMO_VERSION}_linux_amd64.zip -o consul.zip
echo "Installing Consul version ${CONSUL_DEMO_VERSION} ..."

rm -fr /usr/bin/consul /tmp/consul 

unzip -o consul.zip
sudo chmod +x consul
sudo mv consul /usr/bin/consul
sudo mkdir -p /etc/consul.d
sudo chmod a+w /etc/consul.d
sudo mkdir -p /var/consul
sudo cp /home/vagrant/consul.rc /etc/init.d/consul.rc

# Change host 
cat /home/vagrant/config.old.json | jq '.bind_addr="172.20.20.80"' > /home/vagrant/config.json

# START CONSUL
sudo /etc/init.d/consul.rc restart  

# Install Nodejs
apk add nodejs

KIBANA_VERSION="5.2.2"
KIBANA_DOWNLOAD_URL="https://artifacts.elastic.co/downloads/kibana/kibana-${KIBANA_VERSION}-linux-x86_64.tar.gz"

echo "Downloading KIBANA ${KIBANA_VERSION}..."

rm -rf /home/vagrant/kibana-${ES_VERSION} && \
  curl -s ${KIBANA_DOWNLOAD_URL} | gzip -d -c | tar xf - -C /home/vagrant/

# Install
echo "Installing KIBANA..."
test -e /usr/share/kibana && sudo rm -fr /usr/share/kibana 
sudo mv /home/vagrant/kibana-${KIBANA_VERSION}-linux-x86_64 /usr/share/kibana
sudo mv /home/vagrant/kibana.yml /usr/share/kibana/config/kibana.yml
sudo mv /home/vagrant/kibana.rc /etc/init.d/kibana.rc

# create use
id -u kibana &> /dev/null || adduser -DH -s /sbin/nologin kibana

echo "vagrant ALL= (kibana) NOPASSWD: ALL" >> /etc/sudoers

sudo touch /var/log/kibana.log /var/log/kibana.err.log
sudo chown -R kibana /var/log/kibana.log \
  /var/log/kibana.err.log /usr/share/kibana

sudo /etc/init.d/kibana.rc restart

echo "Registering KIBANA to Service Discovery..."
curl -s -H "Content-Type: application/json" -X PUT \
  -d '{"ID":"elasticsearch", "Name":"kibana", "Address":"172.20.20.80","Port":9200}' \
  http://localhost:8500/v1/agent/service/register