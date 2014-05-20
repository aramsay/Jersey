#!/bin/bash
set -x
source /home/scripts/workflow/functions.sh
setpid "$(basename $0)"
#
################################################################################
###
#
#  Only make changes to this section
#
#
#define hostname to connect to
HOST="gp-production.guitonpublishing.com"
#define location of credentials file
AUTHFILE="/root/.smb-cred-guitonpub-ad"
#define volume on host to connect to
VOLUME="Picture_Archive"
# define location of base directory on remote
LOCATION_ON_REMOTE="/Jersey"
# define location of where files will be stored
LOCATION_ON_LOCAL="/data/GUITON/knowledge_files/Picture_Archive/Jersey"
#
# number of files in a batch
BATCH_SIZE=100
#
# Move files to Processed directory on remote : 1 = yes 0 = no(delete)
MOVE_PROCESSED=0
#
# Processed folder name
PROCESSED_FOLDER="Processed"
#
# If using check_local_filecount set Maximum number of files that can exist locally
# before copy can procced
MAX_FILES=1000
#
#####################################################################################
#
# define file mask to search / move
file_mask_file="$(dirname $0)/$(basename $0 .sh).mask"
delete_mask_file="$(dirname $0)/$(basename $0 .sh).delete"
# define temp file
tmp_file="$(dirname $0)/$(basename $0 .sh).tmp"
del_tmp_file="$(dirname $0)/$(basename $0 .sh).deltmp"
#set up command to run on connection - command_string is ; separated
#
date_in_sec=`date "+%s"`
log_file="$(dirname $0)/$(basename $0 .sh).log"

check_local_filecount $LOCATION_ON_LOCAL $MAX_FILES

get_list_smb $HOST $VOLUME $AUTHFILE $LOCATION_ON_REMOTE $file_mask_file $BATCH_SIZE $tmp_file
sleep 20
while read line; do
        copy_from_smb $LOCATION_ON_LOCAL $HOST $VOLUME $AUTHFILE $LOCATION_ON_REMOTE "$line"
        move_smb $HOST $VOLUME $AUTHFILE $LOCATION_ON_REMOTE $PROCESSED_FOLDER "$line" $MOVE_PROCESSED
done < $tmp_file

