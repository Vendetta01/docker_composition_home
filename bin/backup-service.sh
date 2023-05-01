#!/bin/bash
set -eo pipefail
# DEBUG
#set -x

PROG=${0##*/}
BACKUP="/bin/bash $(dirname $0)/docker_backup_volume.sh"

PROG_DIR=$(dirname $0)
PROG_DIR_ABS=$(dirname $0)
if [[ $PROG_DIR =~ ^[^/] ]]; then
    PROG_DIR_ABS=$(pwd)/$PROG_DIR
fi

unset BACKUP_DIR
VOLUMES_YAML_FILE_DEFAULT=${PROG_DIR_ABS}/../docker-compose.base.yml


function usage() {
cat <<EOF
Usage: $PROG [-h] [-f docker-compose.yml] [-b backup_dir] service_name
Backup named volumes of the given service.
 
  Options:
    -h             print this help message.
    -f file_path   path to docker-compose.yml with volume definitions.
    -b backup_dir  path to backup directory.
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


# set default volume yaml file
if [[ -z ${VOLUMES_YAML_FILE+x} ]]; then
    VOLUMES_YAML_FILE=$VOLUMES_YAML_FILE_DEFAULT
fi


# get positional arguments
shift $((OPTIND - 1))
if (($# == 0)); then
    usage
    exit 1
fi


# init volumes
vol_count=0
if [[ $(cat $VOLUMES_YAML_FILE | shyaml keys | grep volumes | wc -l) -ne 0 ]]; then
	for key in $(cat $VOLUMES_YAML_FILE | shyaml keys volumes); do
		service_owner=$(cat $VOLUMES_YAML_FILE | shyaml get-value "volumes.${key}.labels.${key}\.service_owner")
		vol_name=$(cat $VOLUMES_YAML_FILE | shyaml get-value volumes.${key}.name)
		BACKUP_DIR=${PROG_DIR_ABS}/../init/${service_owner}/backup_volumes
		echo "    -> ${vol_name}..."
		$BACKUP ${vol_name} ${BACKUP_DIR}/${vol_name}_$(date +"%Y%m%d%H%M%S").tar.gz
		#((vol_count++)) # produces error in combination with set -e
		let "vol_count=vol_count+1"
	done
else
    echo "    -> Skipped, no volumes in yaml"
fi


# TODO:
# * set symlink to newest backup
# * fix parameter -b to work again
# * fix usage()
# * clean up service_owner and use service_name instead or so...

