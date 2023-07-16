#!bin/bash

set -o allexport
source .env
set +o allexport


addressDir="./address-service" 
ecoDir="./eco-service"

if [ -d "$addressDir/.git" ]; then

  echo "Performing git pull in $addressDir..."
  cd "$addressDir"
  git pull
  cd ..
else

  echo "Performing git clone in $addressDir..."
  git clone -b main https://$GITLAB_USERNAME:$GITLAB_TOKEN@gitlab.si.umich.edu/csdts-umich/af_address_scraping.git "$addressDir"
fi


if [ -d "$ecoDir/.git" ]; then
  echo "Performing git pull in $ecoDir..."
  cd "$ecoDir"
  git pull
  cd ..
else
  echo "Performing git clone in $ecoDir..."
  git clone -b main https://$GITLAB_USERNAME:$GITLAB_TOKEN@gitlab.si.umich.edu/csdts-umich/artisanalfutures-eco-social-calc.git "$ecoDir"
  cd eco-service/data/USEEIO && git lfs install && git lfs pull
  cd ../../
fi





# docker-compose build
# docker-compose up