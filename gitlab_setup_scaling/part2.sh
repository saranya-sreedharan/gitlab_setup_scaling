#!/bin/bash
RED='\033[0;31m'  # Red colored text
NC='\033[0m'      # Normal text
YELLOW='\033[33m'  # Yellow Color
GREEN='\033[32m'   # Green Color
BLUE='\033[34m'    # Blue Color

# Function to handle errors
error_exit() {
    echo -e "${RED}Error: $1${NC}" 1>&2
    exit 1
}

# Trap errors and call error_exit
trap 'error_exit "An error occurred at line $LINENO."' ERR

echo "${YELLOW}...Enter the container_name:...${NC}"
read container_nmae

# Create GitLab backup
echo -e "${YELLOW}...creating GitLab backup...${NC}"
sudo docker exec -it $container_nmae gitlab-backup create STRATEGY=copy || error_exit "Failed to create GitLab backup."

# Find the latest backup created in the container
LATEST_BACKUP=$(sudo docker exec -it $container_nmae ls /var/opt/gitlab/backups/ | grep tar | tail -1 | tr -d '\r')

# Ensure the backup directory exists
mkdir -p /home/operators/Documents/infra/gitlab/backup

# Copy the backup file from the container to the host
echo -e "${YELLOW}...copying backup to host...${NC}"
sudo docker cp gitlab:/var/opt/gitlab/backups/$LATEST_BACKUP /home/operators/Documents/infra/gitlab/backup/$LATEST_BACKUP || error_exit "Failed to copy backup to host."

# Verify backup file
if [ ! -f "/home/operators/Documents/infra/gitlab/backup/$LATEST_BACKUP" ]; then
    error_exit "Backup file not found!"
fi

# Adjust permissions again after copying backup
#sudo chown -R operators:operators /Documents/infra/gitlab
#sudo chmod -R 755 /Documents/infra/gitlab

# Stop and remove GitLab and GitLab Runner containers
echo -e "${YELLOW}...stopping and removing GitLab and GitLab Runner containers...${NC}"
sudo docker stop gitlab gitlab-runner
sudo docker rm gitlab gitlab-runner

echo "${RED}....getting in to sleep for 30 seconds....${NC}"
sleep 30

# Create docker-compose.yml file
echo -e "${YELLOW}...creating docker-compose.yml file...${NC}"
cat <<EOF > /home/operators/Documents/infra/gitlab/docker-compose.yml
version: '3'

services:
  gitlab:
    image: gitlab/gitlab-ee:latest
    ports:
      - "443:443"
      - "80:80"
    volumes:
      - ./config:/etc/gitlab
      - ./logs:/var/log/gitlab
      - ./data:/var/opt/gitlab
      - ./backup:/var/opt/gitlab/backups

  gitlab-runner:
    image: gitlab/gitlab-runner:latest
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
      - ./gitlab_runner_data:/etc/gitlab-runner
EOF

# Navigate to the directory with the docker-compose.yml file
cd /home/operators/Documents/infra/gitlab/

# Start GitLab and GitLab Runner using Docker Compose
echo -e "${YELLOW}...starting GitLab and GitLab Runner with Docker Compose...${NC}"
sudo docker-compose up -d || error_exit "Failed to start GitLab and GitLab Runner with Docker Compose."

# Wait for GitLab to be fully up and running
sleep 120

# Restore GitLab from backup
echo -e "${YELLOW}...restoring GitLab from backup...${NC}"
sudo docker exec -it gitlab gitlab-backup restore BACKUP=$(basename $LATEST_BACKUP .tar) || error_exit "Failed to restore GitLab from backup."

# Scale GitLab Runner to 4 instances
#echo -e "${YELLOW}...scaling GitLab Runner to 4 instances...${NC}"
#sudo docker-compose up -d --scale gitlab-runner=4 || error_exit "Failed to scale GitLab Runner to 4 instances."

#echo -e "${GREEN}GitLab and GitLab Runner setup completed successfully!${NC}"