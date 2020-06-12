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
# Generate Jupyter Notebooks configuration file
jupyter notebook --generate-config

# Create password protection for Jupiter Notebooks
echo -e "\nJupyter Notebook password setup\n"
jupyter notebook password

# Modify Jupyter configurations file
JCT=$(<config_text.txt)
cd ~/.jupyter/
JCF=jupyter_notebook_config.py
cp "$JCF" "$JCF.tmp"

# Merge files
echo "$JCT" $'\n' > "$JCF"
cat "$JCF.tmp" >> "$JCF"
rm -f "$JCF.tmp"

# Generate certificates for HTTPS
cd ~/
mkdir certs
cd certs
openssl req -x509 -nodes -days 365 -newkey rsa:1024 -keyout mycertifications.pem -out mycertifications.pem

# Set user permissions for Jupiter access
sudo chown $USER:$USER /home/ubuntu/certs/mycertifications.pem

# Create directory for Jupyter Notebooks
cd ~
mkdir Notebooks
cd ~/Notebooks

# Initialize Git repository and add pre-commit hooks for automatically compiling
# .ipynb files into .py files
cp ~/AWS_Setup/Jupyter/pre-commit ~/Notebooks/.git/hooks/pre-commit

# AWS Jupyter Notebook setup completed
echo "\nAWS Jupyter Notebook setup completed, enjoy your coding!\n"
