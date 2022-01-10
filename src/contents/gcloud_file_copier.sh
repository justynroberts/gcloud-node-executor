#!/usr/bin/env bash
#----------------------------------------------------------------------------------------------------#
# MIT License

# Copyright (c) 2021 Jake Cohen, Justyn Roberts, Giran Moodley

# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
#f urnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#----------------------------------------------------------------------------------------------------#
GCLOUD="$RD_CONFIG_GCP_GCLOUD_PATH" 
export PATH=$GCLOUD:$PATH
TMPDIR=$RD_CONFIG_GCP_TMPDIR
RANDOM_ID=$RANDOM$RANDOM$RANDOM
SESSION="$RD_CONFIG_GCP_TMPDIR""$RANDOM_ID"
JSON_TOKEN=$RD_CONFIG_GCP_SERVICE_ACCOUNT_TOKEN
CMDOPTS=" "$RD_CONFIG_GCP_ADDITIONALCLI" "

if [ "$RD_CONFIG_GCP_IAPTUNNELLING" == "true" ];then CMDOPTS+=" --tunnel-through-iap";fi
echo "Key Exchange"
echo "$JSON_TOKEN" > "$SESSION".tok 2>&1

# Create temporary configuration
gcloud config configurations create "config-$RANDOM_ID" > /dev/null 2>&1
gcloud config set project $RD_CONFIG_PROJECTID --configuration="config-$RANDOM_ID" > /dev/null 2>&1

# Authenticate service account
gcloud auth activate-service-account --key-file "$SESSION"'.tok' --configuration="config-$RANDOM_ID" > /dev/null 2>&1

# Export service account variables
export service_account=$(gcloud config list account --format "value(core.account)" --configuration="config-$RANDOM_ID")
gcloud config set account $service_account --configuration="config-$RANDOM_ID" > /dev/null 2>&1
#gcloud config set compute/zone $RD_CONFIG_ZONE --configuration="config-$RANDOM_ID" > /dev/null 2>&1
export uniqueId=$(gcloud iam service-accounts describe "$service_account" --format='value(uniqueId)' --configuration="config-$RANDOM_ID")

# Generate temporary SSH key
ssh-keygen -t rsa -f "$SESSION"'.key' -C "USER" -N '' > /dev/null 2>&1
chmod 400 "$SESSION"'.key'
chmod 400 "$SESSION"'.key.pub'

# Use temporary SSH key to login and execute command
gcloud compute os-login ssh-keys add --key-file="$SESSION"'.key.pub' --ttl=2h --configuration="config-$RANDOM_ID" > /dev/null 2>&1
gcloud compute scp sa_"$uniqueId"@"$RD_NODE_HOSTNAME" --ssh-key-file="$SESSION".key  --project="$RD_CONFIG_PROJECTID"  --configuration="config-$RANDOM_ID" $CMDOPTS --zone="$RD_CONFIG_ZONE" "$RD_FILE_COPY_FILE" sa_"$uniqueId"@"$RD_NODE_HOSTNAME":"$RD_FILE_COPY_DESTINATION"
gcloud compute os-login ssh-keys remove --key-file="$SESSION"'.key.pub' --configuration="config-$RANDOM_ID" > /dev/null 2>&1

# Clear up temporary config and SSH keys
gcloud config configurations activate default > /dev/null 2>&1
gcloud config configurations delete "config-$RANDOM_ID" --quiet > /dev/null 2>&1
rm -f "$SESSION"'.key.pub'
rm -f "$SESSION"'.key'
rm -f "$SESSION"'.tok'












