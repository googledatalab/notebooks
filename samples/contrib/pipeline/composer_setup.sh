#!/usr/bin/env bash
# We remove the local installation and install a version that allows custom repositories.
sudo apt-get -y remove google-cloud-sdk

# If an installation still exists after executing apt-get remove, try the following:
# gcloud info --format="value(installation.sdk_root)"
# that'll give you the installation directory of whichever installation gets executed
# you can remove that entire directory. Restart shell, rinse and repeat until gcloud is 
# no longer on your path you might have to clean up your PATH in .bashrc and nuke the 
# .config/gcloud directory

# Hopefully by now the machine is clean, so install gcloud
curl https://sdk.cloud.google.com | CLOUDSDK_CORE_DISABLE_PROMPTS=1 bash

# Recycling shell to pick up the new gcloud.
exec -l $SHELL

# These have to be set here and not on the top of the script because we recycle the shell somewhere
# between the start of this script and here.
PROJECT=${1:-$(gcloud info --format='get(config.project)')}
ZONE=${2:-us-central1}
EMAIL=$3
ENVIRONMENT=${4:-datalab-composer}

gcloud config set project $PROJECT
gcloud config set account $EMAIL
gcloud auth login $EMAIL

gcloud components repositories add https://storage.googleapis.com/composer-trusted-tester/components-2.json
gcloud components update -q
gcloud components install -q alpha kubectl

gcloud config set composer/location $ZONE
gcloud alpha composer environments create $ENVIRONMENT
echo "datalab" > requirements.txt
gcloud alpha composer environments set-python-dependencies $ENVIRONMENT requirements.txt
rm requirements.txt

