#!/bin/bash

RESTORE="/bin/bash $(dirname $0)/docker_restore_volume.sh"
BACKUP_DIR=$(pwd)/$(dirname $0)/../init/db/backup_volumes


$RESTORE postgres-data ${BACKUP_DIR}/postgres-data_latest.tar.gz

