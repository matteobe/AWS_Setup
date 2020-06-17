#!/bin/bash

## Based on the following articles:
# Setup: https://aws.amazon.com/blogs/iot/influxdb-and-grafana-with-aws-iot-to-visualize-time-series-data/
# InfluxDB: https://medium.com/brightergy-engineering/install-and-configure-influxdb-on-amazon-linux-b0c82b38ba2c
# SSL:

# Deploy on AWS on an EC2 instance of type: Amazon Linux AMI 2018.03.0 (HVM), SSD Volume Type

#################### InfluxDB installation ####################################
# Create directories
mkdir -p /opt/influx/{wal,data,ssl}

# Optional: In case multiple partitions exist, then mount them for the specified
# folders
if FALSE; then
  # Create new file systems for WAL and data and mount volumes
  mkfs.ext4 /dev/sdb
  mkfs.ext4 /dev/sdc
  mount /dev/sdb /opt/influx/wal/
  mount /dev/sdc /opt/influx/data/
fi

# Install InfluxDB for Linux 64-bit
wget https://dl.influxdata.com/influxdb/releases/influxdb_1.8.0_amd64.deb
dpkg -i influxdb_1.8.0_amd64.deb
rm influxdb_1.8.0_amd64.deb

## TODO: SSL certificate
# Create SSL key and concatenate with certificate bundle
# cat privkey.pem mysite.crt mysite-ca-bundle.crt > bundle.pem
# scp bundle.pem root@myhost:/tmp

# Update InfluxDB configurations
# mv /tmp/bundle.pem /opt/influx/ssl/
chown -R influxdb:influxdb /opt/influx/
cp /etc/influxdb/influxdb.conf{,-bak}
sed -i 's#/var/lib/influxdb/meta#/opt/influx/data/meta#' /etc/influxdb/influxdb.conf
sed -i 's#/var/lib/influxdb/data#/opt/influx/data/data#' /etc/influxdb/influxdb.conf
sed -i 's#/var/lib/influxdb/wal#/opt/influx/wal#' /etc/influxdb/influxdb.conf
# sed -i 's#/etc/ssl/influxdb.pem#/opt/influx/ssl/bundle.pem#' /etc/influxdb/influxdb.conf
# sed -i "s/https-enabled = false/https-enabled = true/" /etc/influxdb/influxdb.conf

# Request superadmin password
PSWD_SA2=''
printf "\nEnter a password for the InfluxDB superadmin user:"
read -s PSWD_SA
while [[ "$PSWD_SA" != "$PSWD_SA2" ]]
do
  printf "Please verify the password for the InfluxDB superadmin user:"
  read -s PSWD_SA2
done
PSWD_SA2=

# Request nonadmin password
PSWD_NA2=''
printf "\nEnter a password for the InfluxDB nonadmin user:"
read -s PSWD_NA
while [[ "$PSWD_NA" != "$PSWD_NA2" ]]
do
  printf "Please verify the password for the InfluxDB nonadmin user:"
  read -s PSWD_NA2
done
PSWD_NA2=

# Start the InfluxDB deamon
service influxdb start

# Setup users and privileges
curl "http://localhost:8086/query" --data-urlencode "q=CREATE USER superadmin WITH PASSWORD '${PSWD_SA}' WITH ALL PRIVILEGES"
curl "http://localhost:8086/query" --data-urlencode "q=CREATE USER nonadmin WITH PASSWORD '${PSWD_NA}'"
PSWD_SA=
PSWD_NA=

# Create databases
curl "http://localhost:8086/query" --data-urlencode "q=CREATE DATABASE m5stack"

# Set permissions for non-admin user
curl "http://localhost:8086/query" --data-urlencode "q=GRANT all ON tsdb_stage TO nonadmin"
curl "http://localhost:8086/query" --data-urlencode "q=GRANT read ON tsdb_prod TO nonadmin"
curl "http://localhost:8086/query" --data-urlencode "q=GRANT write ON tsdb_dev TO nonadmin"

# Alternative version to setup users is to ask user to manually type the commands
#echo "\nRun the following commands within influx:\n"
#echo "create user superadmin with password 'a_password' with all privileges\n"
#echo "create user nonadmin with password 'another_password'\n"
#echo "grant all on tsdb_stage to nonadmin\n"
#echo "grant READ on tsdb_prod to nonadmin\n"
#echo "grant WRITE on tsdb_dev to nonadmin\n"
# Launch influx and wait for user to perform commands above
#influx

# Stop influx DB, update authentication settings and restart DB
/etc/init.d/influxdb stop
sed -i "s/auth-enabled = false/auth-enabled = true/" /etc/influxdb/influxdb.conf
/etc/init.d/influxdb start

#################### Installation complete ####################################
printf "\nInstallation of InfluxDB completed\n"
