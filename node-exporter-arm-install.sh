#!/bin/bash

# Add colors for better readability
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Function to check if the previous command was successful
check_status() {
    if [ $? -ne 0 ]; then
        echo -e "${RED}✗ Error: $1${NC}"
        exit 1
    fi
}

echo -e "${BLUE}===========================================================${NC}"
echo -e "${BLUE}          NODE EXPORTER INSTALLATION SCRIPT                ${NC}"
echo -e "${BLUE}===========================================================${NC}"

# Get the latest version of node_exporter
echo -e "\n${YELLOW}[1/6]${NC} Detecting latest Node Exporter version..."
LATEST_NODE_EXPORTER_VERSION=$(curl -s https://prometheus.io/download/ | grep -A 1 "node_exporter" | grep -o "[0-9]\+\.[0-9]\+\.[0-9]\+" | head -1)
check_status "Failed to detect latest Node Exporter version"
echo -e "${GREEN}✓${NC} Latest Node Exporter version: ${YELLOW}v${LATEST_NODE_EXPORTER_VERSION}${NC}"

# Download the node_exporter binary
echo -e "\n${YELLOW}[2/6]${NC} Downloading and extracting Node Exporter..."
wget -q https://github.com/prometheus/node_exporter/releases/download/v${LATEST_NODE_EXPORTER_VERSION}/node_exporter-${LATEST_NODE_EXPORTER_VERSION}.linux-arm64.tar.gz
check_status "Failed to download Node Exporter"
tar xfz node_exporter-${LATEST_NODE_EXPORTER_VERSION}.linux-arm64.tar.gz
check_status "Failed to extract Node Exporter archive"
echo -e "${GREEN}✓${NC} Node Exporter downloaded and extracted"

echo -e "\n${YELLOW}[3/6]${NC} Installing Node Exporter to /usr/bin/..."
sudo cp node_exporter-${LATEST_NODE_EXPORTER_VERSION}.linux-arm64/node_exporter /usr/bin/
check_status "Failed to copy Node Exporter to /usr/bin/"
rm -rf ./node_exporter*
check_status "Failed to clean up temporary files"
echo -e "${GREEN}✓${NC} Node Exporter installed successfully"

# Create directory for Node Exporter service file
echo -e "\n${YELLOW}[4/6]${NC} Creating directory for Node Exporter service file..."
sudo mkdir -p /usr/local/src/Node_Exporter
check_status "Failed to create directory for Node Exporter service file"
echo -e "${GREEN}✓${NC} Directory created: /usr/local/src/Node_Exporter"

# Create systemd service file for Node Exporter
echo -e "\n${YELLOW}[5/6]${NC} Creating systemd service file..."
sudo cat > /usr/local/src/Node_Exporter/node-exporter.service << EOF
[Unit]
Description=Node Exporter Service which hosts metrics data about the host for prometheus to collect
[Service]
Type=simple
Restart=always
ExecStart=/usr/bin/node_exporter --collector.systemd --collector.processes
[Install]
WantedBy=multi-user.target
EOF
check_status "Failed to create systemd service file"
echo -e "${GREEN}✓${NC} Service file created at: /usr/local/src/Node_Exporter/node-exporter.service"

# Enable and start Node Exporter service
echo -e "\n${YELLOW}[6/6]${NC} Configuring Node Exporter service..."
echo -e "  ${BLUE}•${NC} Enabling service to start on boot..."
sudo systemctl enable /usr/local/src/Node_Exporter/node-exporter.service
check_status "Failed to enable Node Exporter service"
echo -e "  ${BLUE}•${NC} Starting Node Exporter service..."
sudo service node-exporter start
check_status "Failed to start Node Exporter service"
echo -e "  ${GREEN}✓${NC} Node Exporter service started successfully"

echo -e "\n${GREEN}===========================================================${NC}"
echo -e "${GREEN}✓ NODE EXPORTER INSTALLATION COMPLETE!${NC}"
echo -e "${GREEN}===========================================================${NC}"





