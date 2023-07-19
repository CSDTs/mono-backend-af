#!bin/bash

set -o allexport
source .env
set +o allexport


addressDir="./address-service" 
ecoDir="./eco-service"
productDir="./product-service"
routingDir="./routing-service"
assessmentDir="./assessment-service"
vroomDir="./vroom-service"
if [ -d "$addressDir/.git" ]; then

  echo "Performing git pull in $addressDir..."
  cd "$addressDir"
  git pull
  cd ..
else

  echo "Performing git clone in $addressDir..."
  git clone -b mono https://$GITLAB_USERNAME:$GITLAB_TOKEN@gitlab.si.umich.edu/csdts-umich/af_address_scraping.git "$addressDir"
fi


if [ -d "$ecoDir/.git" ]; then
  echo "Performing git pull in $ecoDir..."
  cd "$ecoDir"
  git pull
  cd ..
else
  echo "Performing git clone in $ecoDir..."
  git clone -b mono https://$GITLAB_USERNAME:$GITLAB_TOKEN@gitlab.si.umich.edu/csdts-umich/artisanalfutures-eco-social-calc.git "$ecoDir"
  cd eco-service/data/USEEIO && git lfs install && git lfs pull
  cd ../../../
fi

if [ -d "$productDir/.git" ]; then
  echo "Performing git pull in $productDir..."
  cd "$productDir"
  git pull
  cd ..
else
  echo "Performing git clone in $productDir..."
  git clone -b dev https://$GITLAB_USERNAME:$GITLAB_TOKEN@gitlab.si.umich.edu/csdts-umich/csdt-misc/product-search.git "$productDir"
fi


if [ -d "$routingDir/.git" ]; then
  echo "Performing git pull in $routingDir..."
  cd "$routingDir"
  git pull
  cd ..
else
  echo "Performing git clone in $routingDir..."
  git clone -b main https://$GITHUB_ACCESS@github.com/CSDTs/af-routing-service.git  "$routingDir"
fi


if [ -d "$assessmentDir/.git" ]; then
  echo "Performing git pull in $assessmentDir..."
  cd "$assessmentDir"
  git pull
  cd ..
else
  echo "Performing git clone in $assessmentDir..."
  git clone -b mono https://$GITLAB_USERNAME:$GITLAB_TOKEN@gitlab.si.umich.edu/csdts-umich/csdt-misc/product-search-with-eco-social.git "$assessmentDir"
fi


if [ -d "$vroomDir/.git" ]; then
  echo "Performing git pull in $vroomDir..."
  cd "$vroomDir"
  git pull
  cd ..
else
  echo "Performing git clone in $vroomDir..."
   git clone -b main https://$GITHUB_ACCESS@github.com/CSDTs/vroom-routing-service-af.git "$vroomDir"
fi

# if which docker-compose >/dev/null 2>&1; then
#     echo "docker-compose is installed."
#     docker-compose build
#     docker-compose up
# else
#     echo "docker-compose is not installed."
# fi
