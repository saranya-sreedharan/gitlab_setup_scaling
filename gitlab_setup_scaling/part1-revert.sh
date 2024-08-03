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

# Stop and remove GitLab and GitLab Runner containers
echo -e "${YELLOW}Stopping and removing GitLab container...${NC}"
sudo docker stop gitlab || error_exit "Failed to stop GitLab container."
sudo docker rm gitlab || error_exit "Failed to remove GitLab container."

echo -e "${YELLOW}Stopping and removing GitLab Runner container...${NC}"
sudo docker stop gitlab-runner || error_exit "Failed to stop GitLab Runner container."
sudo docker rm gitlab-runner || error_exit "Failed to remove GitLab Runner container."

# Remove created directories
echo -e "${YELLOW}Removing directories...${NC}"
rm -rf /home/operators/Documents/infra/gitlab/config || error_exit "Failed to remove config directory."
rm -rf /home/operators/Documents/infra/gitlab/logs || error_exit "Failed to remove logs directory."
rm -rf /home/operators/Documents/infra/gitlab/data || error_exit "Failed to remove data directory."
rm -rf /home/operators/Documents/infra/gitlab/gitlab_runner_data || error_exit "Failed to remove gitlab_runner_data directory."
rm -rf /home/operators/Documents/infra/gitlab/backup || error_exit "Failed to remove backup directory."

echo -e "${GREEN}Revert operation completed successfully!${NC}"
