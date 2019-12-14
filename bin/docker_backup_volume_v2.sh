#!/bin/bash

if [[ $# -lt 3 ]]; then
  echo "Usage: docker_backup_volume_v2 container-name src-path backup-file-url [-h, --dereference]"
  exit 1
fi

BACKUP_FILE_URL=$(mktemp).tar.gz

if [[ $4 == "-h" || $4 == "--dereference" ]]; then
    ADD_TAR_OPTIONS="-h"
fi

docker exec -it $1 tar -cz $ADD_TAR_OPTIONS -f $BACKUP_FILE_URL -C $2 ./
docker cp $1:$BACKUP_FILE_URL $3
docker exec -it $1 rm -f $BACKUP_FILE_URL

