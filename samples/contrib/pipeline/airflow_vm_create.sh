#!/bin/bash
ZONE=${1:-us-central1-b}

# Make the GCS bucket to store the dags. The name follows a convention between this and the startup
# script for the VM creation, so if this name is changed here, it needs to be changed there as well.
# This will fail if the bucket already exists, and that's ok.
PROJECT_ID=$(gcloud info --format='get(config.project)')
VM_NAME=datalab-airflow
GCS_DAG_BUCKET=$PROJECT_ID-$VM_NAME
gsutil mb gs://$GCS_DAG_BUCKET

# Create the VM.
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
    --metadata startup-script-url=gs://datalab-pipelines/airflow_vm_startup.sh

# TODO(rajivpb): Just for debugging; don't ship with this!
sleep 5s
gcloud compute --project $PROJECT_ID ssh --zone $ZONE $VM_NAME
