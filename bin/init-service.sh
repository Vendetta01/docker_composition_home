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
Usage: $PROG [-h] [-b backup_dir] docker-compose.yml
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
    b)
        BACKUP_DIR=$OPTARG
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


# get positional arguments
shift $((OPTIND - 1))
if (($# == 0)); then
    usage
    exit 1
fi


# set service name
VOLUMES_YAML_FILE=$1


# TODO: backup_dir parameter does not work yet, do we need it???
# TODO: Update usage()

# init volumes
vol_count=0
if [[ $(cat $VOLUMES_YAML_FILE | shyaml keys | grep volumes | wc -l) -ne 0 ]]; then
    for key in $(cat $VOLUMES_YAML_FILE | shyaml keys volumes); do
        vol_name=$(cat $VOLUMES_YAML_FILE | \
            shyaml get-value volumes.${key}.name)
        vol_owner=$(cat $VOLUMES_YAML_FILE | \
            shyaml get-value volumes.${key}.labels.${key}\\.service_owner)
        # set backup dir
        BACKUP_DIR=${PROG_DIR_ABS}/../init/${vol_owner}/backup_volumes
        backup_file_url=${BACKUP_DIR}/${vol_name}_latest.tar.gz
        if [[ -f "$backup_file_url" ]]; then
            echo "    -> ${vol_name}"
            #create_volume "${vol_name}"
            $RESTORE ${vol_name} ${BACKUP_DIR}/${vol_name}_latest.tar.gz
            #((vol_count++)) # sets exit code in combination with set -e
            let "vol_count=vol_count+1"
        else
            echo "    -> ${vol_name}: Skipped, ${backup_file_url} not present"
        fi
    done
else
    echo "    -> Skipped, no volumes in yaml"
fi
