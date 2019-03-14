#!/bin/bash

#############################################################################
# COLOURS AND MARKUP
#############################################################################

red='\033[0;31m'            # Red
green='\033[0;49;92m'       # Green
yellow='\033[0;49;93m'      # Yellow
white='\033[1;37m'          # White
grey='\033[1;49;30m'        # Grey
nc='\033[0m'                # No color

clear

echo -e "${yellow}
# Test if machine is running in swarm if not start it 
#############################################################################${nc}"
# Test if machine is running in swarm if not start it 
#############################################################################${nc}"
if docker node ls > /dev/null 2>&1; then
  echo already running in swarm mode 
else
  docker swarm init 
  echo docker was a standalone node now running in swarm 
fi


echo -e "${yellow}
# Create secrets for db use 
#############################################################################${nc}"
echo -e "${green}Choose new database root password: ${nc}"
read canvas_db_root_pwd
printf $canvas_db_root_pwd | docker secret create canvas_db_root_password -
echo -e "${green}Done....${nc}"

echo -e "${green}Choose new database dba password: ${nc}"
read dbdbapwd
printf $canvas_db_dba_pwd | docker secret create canvas_db_dba_pwd -
echo -e "${green}Done....${nc}"


echo -e "${yellow}
# Setup database for initial use 
#############################################################################${nc}"
docker-compose up -d db
echo -e "${green}Done....${nc}"


echo -e "${yellow}
#Wait a few moments for the database to start then (command might fail if database hasn't finished first time startup):
#############################################################################${nc}"
sleep 15
echo -e "${green}Done....${nc}"


echo -e "${yellow}
# Setup canvas for initial use
# When prompted enter default account email, password, and display name. Also choose to share usage data or not.
#############################################################################${nc}"
docker-compose run --rm app bundle exec rake db:create db:initial_setup
echo -e "${green}Done....${nc}"


echo -e "${yellow}
# Setup canvas for initial use part 2
# The branding assets must also be manually generated when canvas is in production mode:
#############################################################################${nc}"
docker-compose run --rm app bundle exec rake canvas:compile_assets_dev brand_configs:generate_and_upload_all
echo -e "${green}Done....${nc}"


echo -e "${yellow}
# Setup canvas for initial use part 3
# Finally startup all the services (the build will create a docker image for you):
#############################################################################${nc}"
docker-compose up -d --build
echo -e "${green}Done....${nc}"
