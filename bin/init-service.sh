#!/bin/bash
set -eo pipefail
# DEBUG
#set -x

PROG=${0##*/}
RESTORE="/bin/bash $(dirname $0)/docker_restore_volume.sh"

PROG_DIR=$(dirname $0)
PROG_DIR_ABS=$(dirname $0)
if [[ $PROG_DIR =~ ^[^/] ]]; then
    PROG_DIR_ABS=$(pwd)/$PROG_DIR
fi

VOLUMES_YAML_FILE_DEFAULT=${PROG_DIR_ABS}/../docker-compose.base.yml


function usage() {
cat <<EOF
Usage: $PROG [-h] [-f docker-compose.yml] [-b backup_dir] service_name
Initialize volumes of the given service.
 
  Options:
    -h             print this help message.
    -f file_path   path to docker-compose.yml with volume definitions.
EOF
}


# parse command line options
while getopts ":hf:b:" OPT; do
    case "${OPT}" in
    h)
        usage
        exit
        ;;
    f)
        VOLUMES_YAML_FILE=$OPTARG
        ;;
    :)
        echo "Missing option argument for -$OPTARG" >&2
        exit 1
        ;;
    *)
        echo "Unknown option: -$OPTARG" >&2
        usage
        exit 1
        ;;
    esac
done


# set default volumes yaml file
if [[ -z ${VOLUMES_YAML_FILE+x} ]]; then
    VOLUMES_YAML_FILE=$VOLUMES_YAML_FILE_DEFAULT
fi


# get positional arguments
shift $((OPTIND - 1))
if (($# == 0)); then
    usage
    exit 1
fi


# set service name
SERVICE_NAME=${1,,}


# init volumes
vol_count=0
for key in $(cat $VOLUMES_YAML_FILE | shyaml keys volumes); do
    vol_name=$(cat $VOLUMES_YAML_FILE | \
        shyaml get-value volumes.${key}.name)
    vol_owner=$(cat $VOLUMES_YAML_FILE | \
        shyaml get-value volumes.${key}.labels.${key}\\.service_owner)
    # set backup dir
    BACKUP_DIR=${PROG_DIR_ABS}/../init/${vol_owner}/backup_volumes
    backup_file_url=${BACKUP_DIR}/${vol_name}_latest.tar.gz
    if [[ "$vol_owner" == "$SERVICE_NAME" || "$SERVICE_NAME" == "-" ]]; then
        if [[ -f "$backup_file_url" ]]; then
            echo "    -> ${vol_name}"
            #create_volume "${vol_name}"
            $RESTORE ${vol_name} ${BACKUP_DIR}/${vol_name}_latest.tar.gz
            #((vol_count++)) # sets exit code in combination with set -e
            let "vol_count=vol_count+1"
        else
            echo "    -> ${vol_name}: Skipped, ${backup_file_url} not present"
        fi
    fi
done


#if [[ "$vol_count" -lt 1 ]]; then
#    echo "Warning: service has no volumes to initialize"
#fi

