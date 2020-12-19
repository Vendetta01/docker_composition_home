#!/bin/bash

RESTORE="/bin/bash $(dirname $0)/docker_restore_volume.sh"
BACKUP_DIR=$(pwd)/$(dirname $0)/../init/nextcloud/backup_volumes


#$RESTORE nextcloud-config ${BACKUP_DIR}/nextcloud-config_latest.tar.gz

