#!/bin/sh
PLATFORM=$(uname)
BIT=$(uname -m)
JQ=""

function progressInfo {
  printf "\033[1m$1\033[0m...\n"
}

## Detecting OS

printf "\033[32mDidiet's DevBox (c) 2017 Didiet Noor\033[0m\n"
printf "\033[1mBootstrapping DevBox Environment...\033[0m\n"
printf "Platform:\t${PLATFORM}\n"
printf "Machine:\t${BIT}\n"

printf "using jq:\t"
if test "x${BIT}" = "xx86_64";
then
  if test "x${PLATFORM}" = "xlinux";
  then
    JQ="./bins/jq-linux64"
  elif test "x${PLATFORM}" = "xDarwin";
  then
    JQ="./bins/jq-osx-amd64"
  else
    >&2 printf "\n\033[31mError: Unsupported platform. Run this script on Linux or macOS\033[0m\n"
  fi
else
  >&2 printf "\n\033[31mError: This script only runs on x86_64 platform\033[0m\n"
fi
JQ_VERSION=$($JQ --version)
printf "\033[1m${JQ}\033[0m ver: ${JQ_VERSION}\n"

## Downloading Minikube
MINIKUBE_NAME=""
if test "x${PLATFORM}" = "xlinux";
then
  MINIKUBE_NAME="minikube-linux-amd64"
elif test "x${PLATFORM}" = "xDarwin";
then
  MINIKUBE_NAME="minikube-darwin-amd64"
fi

progressInfo "\nDownloading Software"
MINIKUBE_VERSION=$(curl -s https://api.github.com/repos/kubernetes/minikube/releases | jq '.[0].name' | sed 's/^"\(.*\)"$/\1/')
printf "Minikube:\t${MINIKUBE_VERSION}\n"
MINIKUBE_URL="https://storage.googleapis.com/minikube/releases/${MINIKUBE_VERSION}/${MINIKUBE_NAME}"
MINIKUBE=./bins/minikube
curl --progress-bar -Lo ${MINIKUBE} ${MINIKUBE_URL}
chmod ugo+x ${MINIKUBE} 
if test -e ${MINIKUBE} ; 
then 
  printf "Minikube Bins:\t ./bins/minikube" 
fi


progressInfo "\nSetting Up"
printf "Vagrant Version: $(vagrant -v)\n"

vagrant plugin install vagrant-alpine
vagrant up
${MINIKUBE} start --memory 1024 --cpus 1 --host-only-cidr 172.20.20.100/30