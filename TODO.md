# TODO

* [ ] How to resolve domain names (eg. ldap.podewitz.local) in local network so that it is routed to baernas (use dnsmasq-docker) -> dnsmasq-docker as primary dns in router
* [X] Include paperless in docker-compose.yml
* [X] convert paperless to use real webserver (nginx/gunicorn)
* [X] use real database server (postgres) for paperless (maybe?)
* [X] How to properly use confd (in containers?) -> first set up confd through environment variables using itself (-backend env -onetime), then start confd and let it configure the rest (through whatever backend is initially set)
* [X] GUI for etcd
* [X] reverse-proxy for bundeling all webapps together (for now only phpldapadmin and paperless)
* [ ] ldap-user-manager:
    - [X] use groupofnames and members
    - [X] extend group creation with posixGroup and samba stuff
    - [X] extend user creation with samba stuff
    - [X] include samba domain and user/group fields in web interface
    - [X] create new docker image (nginx+php OR separate nginx and php containers)
    - [X] fix starttls issues (ldaps does NOT automatically mean that we use starttls!)
    - [X] get next gid uid from defined location (dn=...)
    - [ ] new page for samba-setup
    - [ ] add address + additional samba fields for user creation
    - [X] fill correct fields (for now the whole name + first name ist saved not last name/first name)
    - [ ] rework config so that it can be read from file
    - [ ] use confd in docker image for configuration
* [X] dnsmasq-docker:
    - [X] remove webproc
    - [X] add supervisord and create separate script for host file watch which then runs through supervisord
    - [X] Add environment variables to configure dnsmasq
    - [X] Maybe watch for config change and reload?
    - [X] Think of way to add own entries during runtime (maybe through confd and etcd?)
* [X] e3w: dir_value is defined in different locations -> correct to achieve single source of truth
* [ ] confd: create test environment to check if templates are correct
* [ ] container need to register in etcd with hostname so that dnsmasq nows about them
* [X] merge all /conf/confd/app into /conf/confd so that all services use the same config backend
* [X] wait-for-it.sh needs a URL, which should be provided to all services in the same way (not hardcoded into environment.sh)
* [X] rewrite service definitions so that all services use one source for the confd configuration (env vars defined for all services)
* [ ] refactor lum-docker to use confd for configuration
* [X] rework backup mechanism for openldap: backup scripts run an exec on the actual service container; service needs host mount for backup folder -> deprecated
* [X] alternative: make container that interfaces with docker (has an installed docker daemon inside) and addresses backup etc. -> deprecated
* [X] all named volumes are automatically initialized from backup if configured in docker-compose.base.yml and a backup file exists
* [ ] implement switch between init from volume backups and init from files
* [ ] phpldapadmin: tools missing for health check
* [ ] openldap: we need the -h option for openldap-config to properly create a backup (symlinked file ldap.conf is otherwise missing) -> add new label with backup options -> does not work, needs online backup which has to be configured differently or script has to be changed to read mount path etc.
* [ ] rework structure (is this useful???):
    - [ ] base project has only essential services: ldap and etcd
    - [ ] all other services are another project which takes its configuration from etcd
* [ ] add bookstack service
* [ ] enhance images for db-admin, db and metabase to use confd for configuration (for metabase this is probabely not possible)
* [ ] rename phpldapadmin to ldap-admin to make it analog to db and hide the "implementation detail" that it uses phpldapadmin
* [ ] rename nginx-proxy to proxy to hide "implementation detail" that it uses nginx
* [ ] rename etcd to config (maybe, see above for reason)
* [X] Backup of db also backs up db-admin, that is wrong!
* [ ] Add automatic switch of latest backup link in backup-service.sh
* [ ] dnsmasq: change etcd entries: entry name is address and if empty take the default ip otherwise take ip inside key
* [ ] add small container to update default ip of services in etcd (somehow watch host ip adress of specified network device)
