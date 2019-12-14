#!/bin/bash

RESTORE="/bin/bash $(dirname $0)/docker_restore_volume.sh"
BACKUP_DIR=$(pwd)/$(dirname $0)/../init/openldap-server/backup_volumes


$RESTORE openldap-data ${BACKUP_DIR}/openldap-data_latest.tar.gz
$RESTORE openldap-config ${BACKUP_DIR}/openldap-config_latest.tar.gz

