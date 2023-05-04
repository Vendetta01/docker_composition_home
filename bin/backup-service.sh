#!/bin/bash
set -eo pipefail
# DEBUG
#set -x


function usage() {
cat <<HELPMSG
Usage: $PROG [-h] [-b backup_dir] docker-compose.yml
Backup named volumes of the given docker-compose.yml file.
 
  Options:
    -h             print this help message.
    -b backup_dir  base path to backup directory.
HELPMSG
}


function main() {
    PROG=${0##*/}
    BACKUP="/bin/bash $(dirname $0)/docker_backup_volume.sh"

    PROG_DIR=$(dirname $0)
    PROG_DIR_ABS=$(dirname $0)
    if [[ $PROG_DIR =~ ^[^/] ]]; then
        PROG_DIR_ABS=$(pwd)/$PROG_DIR
    fi

    # parse command line options
    while getopts ":hf:b:" OPT; do
        case "${OPT}" in
        h)
            usage
            exit
            ;;
        b)
            BACKUP_DIR_BASE=$OPTARG
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


    # set default volume yaml file
    if [[ -z ${BACKUP_DIR_BASE+x} ]]; then
        BACKUP_DIR_BASE=${PROG_DIR_ABS}/../init
    fi


    # get positional arguments
    shift $((OPTIND - 1))
    if (($# == 0)); then
        usage
        exit 1
    fi
    VOLUMES_YAML_FILE=$1


    # init volumes
    vol_count=0
    if [[ $(cat $VOLUMES_YAML_FILE | shyaml keys | grep volumes | wc -l) -ne 0 ]]; then
        for key in $(cat $VOLUMES_YAML_FILE | shyaml keys volumes); do
            vol_name=$(cat $VOLUMES_YAML_FILE | \
                shyaml get-value volumes.${key}.name)
            vol_owner=$(cat $VOLUMES_YAML_FILE | \
                shyaml get-value volumes.${key}.labels.${key}\\.service_owner)
            BACKUP_DIR=${BACKUP_DIR_BASE}/${vol_owner}/backup_volumes
            echo "    -> ${vol_name}..."
            $BACKUP ${vol_name} ${BACKUP_DIR}/${vol_name}_$(date +"%Y%m%d%H%M%S").tar.gz
            #((vol_count++)) # produces error in combination with set -e
            let "vol_count=vol_count+1"
        done
    else
        echo "    -> Skipped, no volumes in yaml"
    fi
}


# TODO:
# * set symlink to newest backup
# * clean up service_owner and use service_name instead or so...


# Don't run script if its sourced (e.g. for testing)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]
then
    main $@
fi
