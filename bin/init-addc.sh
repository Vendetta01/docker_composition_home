#!/bin/bash

RESTORE="/bin/bash $(dirname $0)/docker_restore_volume.sh"
BACKUP_DIR=$(pwd)/$(dirname $0)/../init/addc/backup_volumes


#$RESTORE addc-data ${BACKUP_DIR}/addc-data_latest.tar.gz
#$RESTORE addc-config ${BACKUP_DIR}/addc-config_latest.tar.gz

