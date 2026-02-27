#!/bin/bash

# Service Deployment Script
# Deploys a service from the services/ directory using Docker Compose

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "${SCRIPT_DIR}")"
SERVICES_DIR="${PROJECT_ROOT}/services"

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

usage() {
    echo "Usage: $0 <service-name> [action]"
    echo ""
    echo "Available services:"
    if [ -d "${SERVICES_DIR}" ]; then
        for service in "${SERVICES_DIR}"/*; do
            if [ -d "${service}" ] && [ -f "${service}/docker-compose.yml" ]; then
                echo "  - $(basename "${service}")"
            fi
        done
    else
        echo "  No services found in ${SERVICES_DIR}"
    fi
    echo ""
    echo "Available actions:"
    echo "  deploy    - Deploy/start the service (default)"
    echo "  stop      - Stop the service"
    echo "  restart   - Restart the service"
    echo "  logs      - View service logs"
    echo "  status    - Check service status"
    echo "  update    - Pull latest image and restart"
    echo "  backup    - Backup service data"
    echo ""
    echo "Examples:"
    echo "  $0 navidrome"
    echo "  $0 navidrome deploy"
    echo "  $0 navidrome logs"
    echo "  $0 navidrome update"
}

# Check arguments
if [ $# -lt 1 ]; then
    usage
    exit 1
fi

SERVICE_NAME=$1
ACTION=${2:-deploy}
SERVICE_DIR="${SERVICES_DIR}/${SERVICE_NAME}"

# Verify service exists
if [ ! -d "${SERVICE_DIR}" ]; then
    echo -e "${RED}Error: Service '${SERVICE_NAME}' not found${NC}"
    echo ""
    usage
    exit 1
fi

# Verify docker-compose.yml exists
if [ ! -f "${SERVICE_DIR}/docker-compose.yml" ]; then
    echo -e "${RED}Error: docker-compose.yml not found for service '${SERVICE_NAME}'${NC}"
    exit 1
fi

# Change to service directory
cd "${SERVICE_DIR}"

# Execute action
case $ACTION in
    deploy)
        echo -e "${GREEN}Deploying ${SERVICE_NAME}...${NC}"
        docker compose up -d
        echo ""
        echo -e "${GREEN}Service deployed successfully${NC}"
        echo "View logs: docker compose logs -f"
        echo "Check status: docker compose ps"
        ;;
    
    stop)
        echo -e "${YELLOW}Stopping ${SERVICE_NAME}...${NC}"
        docker compose down
        echo -e "${GREEN}Service stopped${NC}"
        ;;
    
    restart)
        echo -e "${YELLOW}Restarting ${SERVICE_NAME}...${NC}"
        docker compose restart
        echo -e "${GREEN}Service restarted${NC}"
        ;;
    
    logs)
        echo -e "${GREEN}Showing logs for ${SERVICE_NAME} (Ctrl+C to exit)${NC}"
        docker compose logs -f
        ;;
    
    status)
        echo -e "${GREEN}Status for ${SERVICE_NAME}:${NC}"
        docker compose ps
        ;;
    
    update)
        echo -e "${GREEN}Updating ${SERVICE_NAME}...${NC}"
        docker compose pull
        docker compose up -d
        echo -e "${GREEN}Service updated and restarted${NC}"
        ;;
    
    backup)
        BACKUP_NAME="${SERVICE_NAME}-backup-$(date +%Y%m%d-%H%M%S).tar.gz"
        echo -e "${GREEN}Creating backup: ${BACKUP_NAME}${NC}"
        
        if [ -d "./data" ]; then
            tar -czf "${HOME}/${BACKUP_NAME}" ./data
            echo -e "${GREEN}Backup created: ${HOME}/${BACKUP_NAME}${NC}"
            echo "Size: $(du -h "${HOME}/${BACKUP_NAME}" | cut -f1)"
        else
            echo -e "${YELLOW}Warning: No data directory found to backup${NC}"
        fi
        ;;
    
    *)
        echo -e "${RED}Error: Unknown action '${ACTION}'${NC}"
        echo ""
        usage
        exit 1
        ;;
esac
