#!bin/bash

set -o allexport
source .env
set +o allexport


directory="./address-service"  # Specify the directory you want to check

if [ -d "$directory/.git" ]; then
  # Directory contains .git folder
  echo "Performing git pull in $directory..."
  cd "$directory"
  git pull
  cd ..
else
  # Directory doesn't contain .git folder
  echo "Performing git clone in $directory..."
  git clone -b main https://$GITLAB_USERNAME:$GITLAB_TOKEN@gitlab.si.umich.edu/csdts-umich/af_address_scraping.git "$directory"
fi

docker-compose build
docker-compose up