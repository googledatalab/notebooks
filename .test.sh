#!/bin/bash

# Copyright 2016 Google Inc. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except
# in compliance with the License. You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software distributed under the License
# is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express
# or implied. See the License for the specific language governing permissions and limitations under
# the License.

# This file tests (most of) the notebooks in this repository using nbconvert.
#
# A number of the notebooks have prerequisites for passing, so make sure that
# you have
#
#  1. Signed in via gcloud
#  2. Created a Google Cloud Platform project and set its ID in the 'PROJECT_ID'
#     environment variable.
#  3. Enabled billing in that project.
#  4. Created at least one Google Compute Engine VM in that project (this is
#     required by the monitoring 'Getting Started' notebook).
#  5. Created a Stackdriver account, and a Stackdriver group containing one or
#     more Google Compute Engine VMs (this is required by the monitoring 'Group
#     metrics' notebook).
#
# If you do not have the assorted Datalab dependencies installed, then you can
# run this inside of the Datalab kernel gateway environment using the following
# command (assuming you have set the 'PROJECT_ID' variable to your test project):
#
#    docker run -v "$(pwd):/content/notebooks" \
#      -v "${HOME}:/content/datalab" \
#      -e "PROJECT_ID=${PROJECT_ID}" \
#      -e "GOOGLE_APPLICATION_CREDENTIALS=/content/datalab/.config/gcloud/application_default_credentials.json" \
#      --entrypoint /content/notebooks/.test.sh \
#      --workdir /content/notebooks \
#      gcr.io/cloud-datalab/datalab-gateway

EXCLUDE=(
"Introduction to Python.ipynb"
"2. Preprocess.ipynb"
"3. Training.ipynb"
"6. Evaluation and Batch Prediction.ipynb"
"7. HyperParameter Tuning.ipynb"
"UDFs using Code in Cloud Storage.ipynb"
)

function testNotebooks() {
    DIR="${1:-./}"
    IFS=$'\n'
    FAILED_NOTEBOOKS=""
    SEP=$'\n\t'
    COUNT="0"
    EXCLUDE_ARGS=""
    for EXCLUDED_NOTEBOOK in "${EXCLUDE[@]}"; do
        EXCLUDE_ARGS="${EXCLUDE_ARGS} -and -not -name '${EXCLUDED_NOTEBOOK}'"
    done
    SEARCH_CMD="find ${DIR} -name '*.ipynb'${EXCLUDE_ARGS}"
    echo "Search command: ${SEARCH_CMD}"
    for NOTEBOOK in `eval "${SEARCH_CMD}"`; do
        echo "Testing ${NOTEBOOK}"
        jupyter nbconvert --ExecutePreprocessor.enabled=True --ExecutePreprocessor.timeout=300 "${NOTEBOOK}" || FAILED_NOTEBOOKS="${FAILED_NOTEBOOKS}${SEP}${NOTEBOOK}"
        COUNT=$(expr ${COUNT} + 1)
    done
    if [ -n "${FAILED_NOTEBOOKS}" ]; then
        echo "Validation failed for the following notebooks:${FAILED_NOTEBOOKS}"
        exit 1
    else
        echo "Validation passed for ${COUNT} notebooks"
    fi
}

DIR="${1:-./}"
testNotebooks ${DIR}
