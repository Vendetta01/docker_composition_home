#!/bin/bash

if [[ $# -lt 2 ]]; then
  echo "Usage: docker_backup_volume volume_name backup_file_url [-h, --dereference]"
  exit 1
fi

if [[ $(echo "${2:0:1}") != "/" ]]; then
  echo "Error: backup_file_url has to be an absolute url (starting with '/')"
  exit 2
fi

touch $2

if [[ $3 == "-h" || $3 == "--dereference" ]]; then
    ADD_TAR_OPTIONS="-h"
fi

docker run -it --rm -v $1:/volume -v $2:/backup/backup.tar.gz alpine \
  tar -cz $ADD_TAR_OPTIONS -f /backup/backup.tar.gz -C /volume ./

