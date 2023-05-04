#!/bin/bash
set -eo pipefail
# DEBUG
#set -x


function usage() {
cat <<HELPMSG
Usage: $PROG [-h] [-b backup_dir] docker-compose.yml
Initialize volumes of the given docker-compose.yml file.
 
  Options:
    -h             print this help message.
    -b backup_dir  base dir of backup location.
HELPMSG
}


function main() {
    PROG=${0##*/}
    RESTORE="/bin/bash $(dirname $0)/docker_restore_volume.sh"

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

    if [[ -z ${BACKUP_DIR_BASE+x} ]]; then
        BACKUP_DIR_BASE=${PROG_DIR_ABS}/../init
    fi


    # check and set positional arguments
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
            # set backup dir
            backup_file_url=${BACKUP_DIR_BASE}/${vol_owner}/backup_volumes/${vol_name}_latest.tar.gz
            if [[ -f "$backup_file_url" ]]; then
                echo "    -> ${vol_name}"
                $RESTORE ${vol_name} ${backup_file_url}
                #((vol_count++)) # sets exit code in combination with set -e
                let "vol_count=vol_count+1"
            else
                echo "    -> ${vol_name}: Skipped, ${backup_file_url} not present"
            fi
        done
    else
        echo "    -> Skipped, no volumes in yaml"
    fi
}


# Don't run script if its sourced (e.g. for testing)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]
then
    main $@
fi
