#!/bin/bash

#################### Anaconda - Python Setup ##################################
# Download current Anaconda version
wget https://repo.anaconda.com/archive/Anaconda3-2020.02-Linux-x86_64.sh

# Launch Anaconda installer
bash Anaconda3-2020.02-Linux-x86_64.sh
# Clean installation files
rm -f Anaconda3-2020.02-Linux-x86_64.sh

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

#################### Install Python packages ##################################
pip install -U -r requirements.txt

#################### Jupiter Notebook Setup ###################################
# Configure Jupiter Notebooks
jupyter notebook --generate-config

# Create password protection for Jupiter Notebooks
PSWD2=""
echo "Enter a password to protect Jupyter notebooks"
read -s PSWD1
while [[ "$PSWD1" != "$PSWD2" ]]
do
  echo "Please verify your password"
  read -s PSWD2
done

# Generate SHA key based on user password input and delete the password
ipython password_setup.py $PSWD2
PSWD1=
PSWD2=

# Read SHA key and config text and prepare variables for input in config file
SHAK=$(<sha_key.txt)
JCT=$(<config_text.txt)
JCT=${JCT/sha1/SHAK}    # Replace SHA key

# Generate certificates for HTTPS
cd ~/
mkdir certs
cd certs
openssl req -x509 -nodes -days 365 -newkey rsa:1024 -keyout mycertifications.pem -out mycertifications.pem

# Modify Jupyter configurations file
cd ~/.jupyter/
JCF=jupyter_notebook_config.py
cp "$JCF" "$JCF.tmp"
# Print modified SHA key in configuration file and append tmp version
echo "$JCT" $'\n' > "$JCF"
cat "$JCF.tmp" >> "$JCF"
rm -f "$JCF.tmp"

# Set user permissions for Jupiter access
sudo chown $USER:$USER /home/ubuntu/certs/mycertifications.pem
