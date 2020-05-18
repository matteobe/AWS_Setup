#!/bin/bash

#################### Anaconda - Python Setup ##################################
# Download current Anaconda version
wget https://repo.anaconda.com/archive/Anaconda3-2020.02-Linux-x86_64.sh

# Launch Anaconda installer
bash Anaconda3-2020.02-Linux-x86_64.sh

# Check that the PATH variable contains the Anaconda environment
SUB='anaconda3/bin'
if [[ "$PATH" != *"$SUB"* ]]; then
  export PATH=/home/ubuntu/anaconda3/bin:$PATH
fi

# Check that Anaconda is the preferred environment
PENV=$(which python)
if [[ "$PENV" != *"$SUB"* ]]; then
  echo "Anaconda is NOT the current Python environment"
fi

#################### Jupiter Notebook Setup ###################################
# Configure Jupiter Notebooks
jupyter notebook --generate-config

# Create password protection for Jupiter Notebooks
PSWD2=''
echo "Enter a password to protect Jupiter notebooks"
read PSWD1
while [[ "$PSWD1" != "$PSWD2" ]]
do
  echo "Please verify your password"
  read PSWD2
done

# Generate SHA1 key based on user password input and substitute it in config file
SHAK=$(ipython password_setup.py)
sed -i "s/sha1/${SHAK}/g" config_text.txt

# Read in text to be added to Jupiter config file
JCT=$(<config_text.txt)

# Generate certificates for HTTPS
cd ~/
mkdir certs
cd certs
openssl req -x509 -nodes -days 365 -newkey rsa:1024 -keyout mycertifications.pem -out mycertifications.pem

# Configure Jupiter
cd ~/.jupyter/
##### ERROR with regex to be fixed ###############
sed -i "1,14s/^/$JCT/" jupyter_notebook_config.pyc

# Set user permissions for Jupiter access
sudo chown $USER:$USER /home/ubuntu/certs/mycertifications.pem
