#!/bin/sh
#----------------------------------------------------------------------------------------------------#
# MIT License

# Copyright (c) 2021 <Authors Here>

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
SESSION="$RD_CONFIG_GCP_TMPDIR""$RD_JOB_ID"
JSON_TOKEN=$RD_CONFIG_GCP_SERVICE_ACCOUNT_TOKEN
CMDOPTS=" "$RD_CONFIG_GCP_ADDITIONALCLI" "

if [ "$RD_CONFIG_GCP_IAPTUNNELLING" == "true" ];then CMDOPTS+=" --tunnel-through-iap";fi
echo "Key Exchange"
echo "$JSON_TOKEN" > "$SESSION".tok 2>&1

gcloud auth activate-service-account --key-file "$SESSION"'.tok' > /dev/null 2>&1
export service_account=$(gcloud config list account --format "value(core.account)")
export uniqueId=$(gcloud iam service-accounts describe "$service_account" --format='value(uniqueId)')

ssh-keygen -t rsa -f "$SESSION"'.key' -C "USER" -N '' > /dev/null 2>&1
chmod 400 "$SESSION"'.key'
chmod 400 "$SESSION"'.key.pub'

gcloud compute os-login ssh-keys add --key-file="$SESSION"'.key.pub' --ttl=2h > /dev/null 2>&1
gcloud compute ssh sa_"$uniqueId"@"$RD_NODE_HOSTNAME" --ssh-key-file="$SESSION".key  --project="$RD_CONFIG_GCP_PROJECT" $CMDOPTS --zone="$RD_CONFIG_GCP_ZONE" --ssh-flag="-T" --command="$RD_EXEC_COMMAND"
gcloud compute os-login ssh-keys remove --key-file="$SESSION"'.key.pub' > /dev/null 2>&1

rm -f "$SESSION"'.key.pub'
rm -f "$SESSION"'.key'
rm -f "$SESSION"'.tok'
