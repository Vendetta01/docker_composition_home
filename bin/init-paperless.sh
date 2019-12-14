#!/bin/bash

RESTORE="/bin/bash $(dirname $0)/docker_restore_volume.sh"
BACKUP_DIR=$(pwd)/$(dirname $0)/../init/paperless/backup_volumes


$RESTORE paperless-data ${BACKUP_DIR}/paperless-data_latest.tar.gz
$RESTORE paperless-media ${BACKUP_DIR}/paperless-media_latest.tar.gz

