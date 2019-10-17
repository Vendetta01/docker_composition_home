#!/bin/bash

RESTORE=$(dirname $0)/docker_restore_volume.sh


$RESTORE paperless-data $(pwd)/$(dirname $0)/../init/paperless/backup/paperless-data_latest.tar.gz
$RESTORE paperless-media $(pwd)/$(dirname $0)/../init/paperless/backup/paperless-media_latest.tar.gz

