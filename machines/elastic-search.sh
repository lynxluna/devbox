#!/bin/sh
set -e 
echo "https://alpine.ykode.com/alpine/v3.4/main" > /etc/apk/repositories
echo "https://alpine.ykode.com/alpine/v3.4/community" >> /etc/apk/repositories

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
mv /home/vagrant/config.json /home/vagrant/config.old.json
cat /home/vagrant/config.old.json | jq '.bind_addr="172.20.20.70"' > /home/vagrant/config.json

# START CONSUL
sudo /etc/init.d/consul.rc restart  

echo "Installing Java 8 from community repo..."
apk add --update openjdk8 curl 
JAVA_HOME=/usr/lib/jvm/default-jvm
PATH=$PATH:$JAVA_HOME/bin
export PATH JAVA_HOME

JAVA_VERSION=$(java -Xmx32m -version 2>&1 | awk -F '"' '/version/ {print $2}')
JAVAC_VERSION=$(javac -J-Xmx32m -version 2>&1)

echo "Java Installed: ${JAVA_VERSION}"

echo "Fetching ElasticSearch..."

ES_VERSION="5.2.2"
ES_DOWNLOAD_URL="https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-${ES_VERSION}.tar.gz"
rm -rf /home/vagrant/elasticsearch-${ES_VERSION} && \
  curl -s ${ES_DOWNLOAD_URL} | gzip -d -c | tar xf - -C /home/vagrant/

echo "vagrant ALL= (elasticsearch) NOPASSWD: /usr/share/elasticsearch/bin/elasticsearch" >> /etc/sudoers

sudo cp -a /home/vagrant/sysctl-es.conf /etc/sysctl.d/
sudo sysctl -p /etc/sysctl.d/sysctl-es.conf 

rm -rf /usr/share/elasticsearch && \
  sudo mv /home/vagrant/elasticsearch-${ES_VERSION} /usr/share/elasticsearch

sudo cp /home/vagrant/elasticsearch.yml /usr/share/elasticsearch/config/elasticsearch.yml
sudo cp /home/vagrant/elasticsearch.rc /etc/init.d/

mkdir -p /usr/share/elasticsearch/data /usr/share/elasticsearch/logs /usr/share/elasticsearch/config/scripts

id -u elasticsearch &> /dev/null || adduser -DH -s /sbin/nologin elasticsearch
sudo touch /var/log/elasticsearch.log /var/log/elasticsearch.err.log  
sudo chown -R elasticsearch:elasticsearch /usr/share/elasticsearch \
  /var/log/elasticsearch.log /var/log/elasticsearch.err.log  

export PATH=$PATH:/usr/share/elasticsearch/bin

sudo /etc/init.d/elasticsearch.rc restart

echo "Registering Elastic Search to Service Discovery"

curl -s -H "Content-Type: application/json" -X PUT \
  -d '{"ID":"elasticsearch", "Name":"es", "Address":"172.20.20.70","Port":9200,"check":{"script":"curl http://172.20.20.70:9200 > /dev/null 2>&1", "interval":"10s"}}' \
  http://localhost:8500/v1/agent/service/register
  
test $? = 0 && echo "Done." || echo "Registration Failed"