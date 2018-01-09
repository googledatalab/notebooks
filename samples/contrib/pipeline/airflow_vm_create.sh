#!/bin/bash
ZONE=${1:-us-central1-b}

# Make the GCS bucket to store the dags. The name follows a convention between this and the startup
# script for the VM creation, so if this name is changed here, it needs to be changed there as well.
# This will fail if the bucket already exists, and that's ok.
PROJECT_ID=$(gcloud info --format='get(config.project)')
GCS_DAG_BUCKET=$PROJECT_ID-datalab-airflow
gsutil mb gs://$GCS_DAG_BUCKET

# Create the VM.
VM_NAME=datalab-airflow
gcloud beta compute --project $PROJECT_ID instances create $VM_NAME \
    --zone $ZONE \
    --machine-type "n1-standard-1" \
    --network "default" \
    --maintenance-policy "MIGRATE" \
    --scopes "https://www.googleapis.com/auth/cloud-platform" \
    --min-cpu-platform "Automatic" \
    --image "debian-9-stretch-v20171025" \
    --image-project "debian-cloud" \
    --boot-disk-size "10" \
    --boot-disk-type "pd-standard" \
    --boot-disk-device-name $VM_NAME \
    --metadata startup-script='#!/bin/bash
apt-get --assume-yes install python-pip

# TODO(rajivpb): Replace this with "pip install datalab"
DATALAB_TAR=datalab-1.1.0.tar
gsutil cp gs://datalab-pipelines/$DATALAB_TAR $DATALAB_TAR
pip install $DATALAB_TAR
rm $DATALAB_TAR

pip install apache-airflow==1.9.0
export AIRFLOW_HOME=/airflow
export AIRFLOW__CORE__DAGS_ARE_PAUSED_AT_CREATION=False
export AIRFLOW__CORE__LOAD_EXAMPLES=False
airflow initdb
airflow scheduler &

# We append a gsutil rsync command to the cron file and have this run every minute to sync dags.
PROJECT_ID=$(gcloud info --format="get(config.project)")
GCS_DAG_BUCKET=$PROJECT_ID-datalab-airflow
AIRFLOW_CRON=temp_crontab.txt
crontab -l > $AIRFLOW_CRON
DAG_FOLDER="dags"
LOCAL_DAG_PATH=$AIRFLOW_HOME/$DAG_FOLDER
echo "* * * * * gsutil rsync gs://$GCS_DAG_BUCKET/$DAG_FOLDER $LOCAL_DAG_PATH" >> $AIRFLOW_CRON
crontab $AIRFLOW_CRON
rm $AIRFLOW_CRON
EOF'

