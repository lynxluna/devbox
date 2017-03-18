#!/bin/sh

echo "https://alpine.ykode.com/alpine/v3.3/main" > /etc/apk/repositories
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

unzip consul.zip
sudo chmod +x consul
sudo mv consul /usr/bin/consul
sudo mkdir -p /etc/consul.d
sudo chmod a+w /etc/consul.d
sudo mkdir -p /var/consul
sudo cp /home/vagrant/consul.rc /etc/init.d/consul.rc
sudo /etc/init.d/consul.rc restart  