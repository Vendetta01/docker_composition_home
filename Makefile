
SERVICES := etcd ldap phpldapadmin e3w lum nginx-proxy dnsmasq paperless metabase db db-admin

RUN_SERVICES := $(SERVICES:%=run-%)
CLEAN_RUN_SERVICES := $(SERVICES:%=clean-run-%)
INIT_SERVICES := $(SERVICES:%=init-%)
BUILD_SERVICES := $(SERVICES:%=build-%)
BACKUP_SERVICES := $(SERVICES:%=backup-%)
COMPOSE_FILES := -f docker-compose.base.yml $(SERVICES:%=-f services/docker-compose.%.yml)

.PHONY: run run-daemon clean build clean-run clean-run-daemon stop $(RUN_SERVICES) $(CLEAN_RUN_SERVICES) $(BUILD_SERVICES) $(INIT_SERVICES) init


run:
	@echo "Running all services..."
	docker-compose $(COMPOSE_FILES) up

run-daemon:
	@echo "Running all services (daemon mode)..."
	docker-compose $(COMPOSE_FILES) up -d

pull:
	@echo "Pulling docker images..."
	docker-compose $(COMPOSE_FILES) pull

$(RUN_SERVICES):
	@echo "Running $(@:run-%=%)..."
	docker-compose $(COMPOSE_FILES) up $(@:run-%=%)

clean:
	@echo "Cleaning all services..."
	-docker-compose $(COMPOSE_FILES) down -v --remove-orphans

check-config:
	docker-compose $(COMPOSE_FILES) config

build: $(BUILD_SERVICES)

$(BUILD_SERVICES):
	@echo "Building $(@:build-%=%)..."
	make -C $(@:build-%=%-docker) build

clean-run: stop clean init run

clean-run-daemon: stop clean init run-daemon

$(CLEAN_RUN_SERVICES): clean-run-%: clean init run-%

init: $(INIT_SERVICES)

$(INIT_SERVICES):
	@echo "Initializing $(@:init-%=%)..."
#       start service to properly create volume from config
	@docker-compose $(COMPOSE_FILES) up --no-start $(@:init-%=%)
	@/bin/bash ./bin/init-service.sh $(@:init-%=%)

stop:
	-docker-compose $(COMPOSE_FILES) down

backup: $(BACKUP_SERVICES)

$(BACKUP_SERVICES):
	@echo "Backing up mounts of service $(@:backup-%=%)..."
	@/bin/bash ./bin/backup-service.sh $(@:backup-%=%)

