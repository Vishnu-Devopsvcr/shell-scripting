#!/bin/sh
# Author : Mohan Kumar [mohan.kumar@flexydial.com]
# Description : Image pull fromo HSL flexydial project registry

RED='\033[0;31m'
Green='\033[0;32m'
NC='\033[0m' # No Color

echo "${RED} Trying docker login into gcr registry....${NC}"
echo '\n'

# Check if a token was provided as a command line argument
if [ -z "$1" ]; then
  # If no token was provided, ask for one
  echo "Enter your GCR registry token here:"
  read token
else
  # If a token was provided, use it
  token="$1"
fi

echo "$token" | sudo docker login -uoauth2accesstoken --password-stdin https://gcr.io

# Check if the login was successful
if [ $? -eq 0 ]; then
  echo "Docker login successful, proceeding..."
else
  echo "Docker login failed, exiting..."
  exit 1
fi

echo "\n"
echo "${RED} Pulling flexydial image from gcr registry....${NC}"
echo "\n"

docker pull gcr.io/hsl-gcp-prd-app-buzzwk-prj-spk/flexydial-app:roll

echo "\n"
echo "${Green}Image pulled successfully...!${NC}"
echo "\n"
echo "${RED}Now, retagging the image${NC}"

sleep 3
docker tag gcr.io/hsl-gcp-prd-app-buzzwk-prj-spk/flexydial-app:roll vedakatta/flexydial-app:latest 

echo "${Green}retag completed...!${NC}"
echo '\n'

echo "${RED}Now, restarting the CDR, Autodial & Audio-FS containers to use latest image${NC}"
echo "\n"
echo "${RED}restarting cdrd container service........${NC}"

/usr/bin/systemctl restart flexydial-cdrd-docker.service

echo "${Green}cdr restart completed....!${NC}"
echo "\n"
echo "${RED}restarting autodial container service........${NC}"

/usr/bin/systemctl restart flexydial-autodial-docker.service

echo "${Green} autodial restart completed....!${NC}"
echo "\n"
echo "${RED}restarting audio-fs container service........${NC}"

/usr/bin/systemctl restart flexydial-audio-fs-docker.service

echo "${Green}audio-fs restart completed....!${NC}"
echo "\n"
echo "${RED}restarting rec-fo-push container service........${NC}"

/usr/bin/systemctl restart flexydial-rec-fo-push-docker.service

echo "${Green}rec-fo-push restart completed....!${RED}Run 'docker ps' command to check the container running status${NC}"
