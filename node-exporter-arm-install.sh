#!/bin/bash

# Add colors for better readability
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}===========================================================${NC}"
echo -e "${BLUE}          NODE EXPORTER INSTALLATION SCRIPT                ${NC}"
echo -e "${BLUE}===========================================================${NC}"

# Get the latest version of node_exporter
echo -e "\n${YELLOW}[1/6]${NC} Detecting latest Node Exporter version..."
LATEST_NODE_EXPORTER_VERSION=$(curl -s https://prometheus.io/download/ | grep -A 1 "node_exporter" | grep -o "[0-9]\+\.[0-9]\+\.[0-9]\+" | head -1)
echo -e "${GREEN}✓${NC} Latest Node Exporter version: ${YELLOW}v${LATEST_NODE_EXPORTER_VERSION}${NC}"

# Download the node_exporter binary
echo -e "\n${YELLOW}[2/6]${NC} Downloading and extracting Node Exporter..."
wget -q https://github.com/prometheus/node_exporter/releases/download/v${LATEST_NODE_EXPORTER_VERSION}/node_exporter-${LATEST_NODE_EXPORTER_VERSION}.linux-arm64.tar.gz
tar xfz node_exporter-${LATEST_NODE_EXPORTER_VERSION}.linux-arm64.tar.gz
echo -e "${GREEN}✓${NC} Node Exporter downloaded and extracted"

echo -e "\n${YELLOW}[3/6]${NC} Installing Node Exporter to /usr/bin/..."
sudo cp node_exporter-${LATEST_NODE_EXPORTER_VERSION}.linux-arm64/node_exporter /usr/bin/
rm -rf ./node_exporter*
echo -e "${GREEN}✓${NC} Node Exporter installed successfully"

# Create directory for Node Exporter service file
echo -e "\n${YELLOW}[4/6]${NC} Creating directory for Node Exporter service file..."
mkdir -p /usr/local/src/Node_Exporter
echo -e "${GREEN}✓${NC} Directory created: /usr/local/src/Node_Exporter"

# Create systemd service file for Node Exporter
echo -e "\n${YELLOW}[5/6]${NC} Creating systemd service file..."
cat > /usr/local/src/Node_Exporter/node-exporter.service << EOF
[Unit]
Description=Node Exporter Service which hosts metrics data about the host for prometheus to collect
[Service]
Type=simple
Restart=always
ExecStart=/usr/bin/node_exporter --collector.systemd --collector.processes
[Install]
WantedBy=multi-user.target
EOF
echo -e "${GREEN}✓${NC} Service file created at: /usr/local/src/Node_Exporter/node-exporter.service"

# Enable and start Node Exporter service
echo -e "\n${YELLOW}[6/6]${NC} Configuring Node Exporter service..."
echo -e "  ${BLUE}•${NC} Enabling service to start on boot..."
sudo systemctl enable /usr/local/src/Node_Exporter/node-exporter.service
echo -e "  ${BLUE}•${NC} Starting Node Exporter service..."
sudo service node-exporter start

echo -e "\n${GREEN}===========================================================${NC}"
echo -e "${GREEN}✓ NODE EXPORTER INSTALLATION COMPLETE!${NC}"
echo -e "${GREEN}===========================================================${NC}"
echo -e "\n${BLUE}Node Exporter metrics should now be available at:${NC}"
echo -e "${YELLOW}http://$(hostname -I | awk '{print $1}'):9100/metrics${NC}\n"





