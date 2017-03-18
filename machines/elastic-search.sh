#!/bin/sh
set -e 
echo "https://alpine.ykode.com/alpine/v3.3/main" > /etc/apk/repositories
echo "https://alpine.ykode.com/alpine/v3.3/community" >> /etc/apk/repositories

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

sudo /etc/init.d/elasticsarch.rc restart