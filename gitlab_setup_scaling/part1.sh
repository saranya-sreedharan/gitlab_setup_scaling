#!/bin/bash

# Define colors
RED='\033[0;31m'
NC='\033[0m'      # No Color
YELLOW='\033[33m'
GREEN='\033[32m'

# Function to handle errors
error_exit() {
    echo -e "${RED}Error: $1${NC}" 1>&2
    exit 1
}

# Trap errors and call error_exit
trap 'error_exit "An error occurred at line $LINENO."' ERR

# Create necessary directories
mkdir -p /home/operators/Documents/infra/gitlab/config /home/operators/Documents/infra/gitlab/logs /home/operators/Documents/infra/gitlab/data /home/operators/Documents/infra/gitlab/gitlab_runner_data /home/operators/Documents/infra/gitlab/backup

# Run GitLab container
echo -e "${YELLOW}Starting GitLab container...${NC}"
sudo docker run --detach \
  --publish 443:443 --publish 80:80 \
  --name gitlab \
  --restart always \
  --volume /home/operators/Documents/infra/gitlab/config:/etc/gitlab \
  --volume /home/operators/Documents/infra/gitlab/logs:/var/log/gitlab \
  --volume /home/operators/Documents/infra/gitlab/data:/var/opt/gitlab \
  gitlab/gitlab-ee:latest || error_exit "Failed to start GitLab container."

# Run GitLab Runner container
echo -e "${YELLOW}Starting GitLab Runner container...${NC}"
sudo docker run --detach \
  --name gitlab-runner \
  --restart always \
  --volume /var/run/docker.sock:/var/run/docker.sock \
  --volume /home/operators/Documents/infra/gitlab/gitlab_runner_data:/etc/gitlab-runner \
  gitlab/gitlab-runner:latest || error_exit "Failed to start GitLab Runner container."

echo -e "${GREEN}GitLab and GitLab Runner setup completed successfully!${NC}"

echo -e "${GREEN} run... sudo docker exec -it gitlab cat /etc/gitlab/initial_root_password for pasword${NC}"

#sudo docker exec -it gitlab cat /etc/gitlab/initial_root_password

#Create some directories and upload some files in each directory