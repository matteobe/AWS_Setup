#!/bin/bash

## Based on the following articles:
# Setup: https://aws.amazon.com/blogs/iot/influxdb-and-grafana-with-aws-iot-to-visualize-time-series-data/
# InfluxDB: https://medium.com/brightergy-engineering/install-and-configure-influxdb-on-amazon-linux-b0c82b38ba2c
# AWS: https://aws.amazon.com/blogs/iot/influxdb-and-grafana-with-aws-iot-to-visualize-time-series-data/
# Grafana: https://grafana.com/grafana/download
# SSL:

# Deploy on AWS on a Ubuntu Server instance

#################### Grafana installation #####################################
# Get Grafana and install it
apt-get install -y adduser libfontconfig1
wget https://dl.grafana.com/oss/release/grafana_7.0.3_amd64.deb
dpkg -i grafana_7.0.3_amd64.deb
rm grafana_7.0.3_amd64.deb

# Start the Grafana server
systemctl daemon-reload
systemctl start grafana-server

#################### Grafana configuration ####################################


#################### Installation complete ####################################
printf "\nInstallation of Grafana completed\n"
printf "Please connect to the server and reset the admin password.\n"
printf "To connect to the dashboard go to http://localhost:3000\n"
