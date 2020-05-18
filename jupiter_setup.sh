#!/bin/bash

# Download current Anaconda version
wget https://repo.anaconda.com/archive/Anaconda3-2020.02-Linux-x86_64.sh

# Launch Anaconda installer
bash Anaconda3-2020.02-Linux-x86_64.sh

# Check that the PATH variable contains the Anaconda environment
SUB='anaconda3/bin'
if [ ! grep -q "$SUB" <<< "$PATH"]; then
  export PATH=/home/ubuntu/anaconda3/bin:$PATH
fi

# Check that Anaconda is the preferred environment
PENV='which python'
if [ grep -q "$SUB" <<< "$PENV"]; then
  echo "Anaconda is the current Python environment"
fi

# Configure Jupiter Notebooks
jupyter notebook --generate-config
JCT=$(<jupiter_config_text.txt)

# Generate certificates for HTTPS
mkdir certs
cd certs
openssl req -x509 -nodes -days 365 -newkey rsa:1024 -keyout mycert.pem -out mycert.pem

# Configure Jupiter
cd ~/.jupiter/
sed -i '1,xs/^/c = get_config()\n/' jupyter_notebook_config.py
