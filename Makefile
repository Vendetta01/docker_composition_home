
#SERVICES := etcd ldap ldap-admin e3w lum reverse-proxy dnsmasq paperless metabase db db-admin home airflow budget

SERVICES := base admin paperless


RUN_SERVICES := $(SERVICES:%=run-%)
RUN_SERVICES_DEBUG := $(SERVICES:%=debug-%)
STOP_SERVICES := $(SERVICES:%=stop-%)
CLEAN_SERVICES := $(SERVICES:%=clean-%)
CLEAN_RUN_SERVICES := $(SERVICES:%=clean-run-%)
INIT_SERVICES := $(SERVICES:%=init-%)
BUILD_SERVICES := $(SERVICES:%=build-%)
BACKUP_SERVICES := $(SERVICES:%=backup-%)
COMPOSE_FILES_BASE := -f docker-compose.base.yml
COMPOSE_FILES_ALL := $(COMPOSE_FILES_BASE) $(SERVICES:%=-f services/docker-compose.%.yml)

#.PHONY: run run-nodaemon clean build clean-run clean-run-nodaemon stop $(RUN_SERVICES) $(CLEAN_RUN_SERVICES) $(BUILD_SERVICES) $(INIT_SERVICES) init
.PHONY: test $(RUN_SERVICES) $(RUN_SERVICES_DEBUG) $(STOP_SERVICES) $(CLEAN_SERVICES) \
	$(INIT_SERVICES) $(CLEAN_RUN_SERVICES) stop-all clean-all init-all

test:
	@echo "Test: $(RUN_SERVICES)"

$(RUN_SERVICES):
	@echo "Running $(@:run-%=%)..."
	docker-compose $(COMPOSE_FILES_BASE) -f services/docker-compose.$(@:run-%=%).yml up -d

$(RUN_SERVICES_DEBUG):
	@echo "Debugging $(@:run-%=%)..."
	docker-compose $(COMPOSE_FILES_BASE) -f services/docker-compose.$(@:run-%=%).yml up

$(STOP_SERVICES):
	-docker-compose $(COMPOSE_FILES_BASE) -f services/docker-compose.$(@:stop-%=%).yml down

$(CLEAN_SERVICES):
	@echo "Cleaning $(@:clean-%=%)..."
	-docker-compose $(COMPOSE_FILES_BASE) -f services/docker-compose.$(@:clean-%=%).yml down -v

$(INIT_SERVICES):
	@echo "Initializing $(@:init-%=%)..."
#	start service to properly create volume from config
	@docker-compose $(COMPOSE_FILES_BASE) -f services/docker-compose.$(@:init-%=%).yml up --no-start
	@/bin/bash ./bin/init-service.sh -f services/docker-compose.$(@:init-%=%).yml -

$(CLEAN_RUN_SERVICES): clean-run-%: clean-% init-% run-%



stop-all:
	-docker-compose $(COMPOSE_FILES_ALL) down

clean-all:
	@echo "Cleaning all services..."
	-docker-compose $(COMPOSE_FILES_ALL) down -v --remove-orphans

init-all: $(INIT_SERVICES)

# run:
# 	@echo "Running all services (daemon mode)..."
# 	docker-compose $(COMPOSE_FILES) up -d

# run-nodaemon:
# 	@echo "Running all services (interactive mode)..."
# 	docker-compose $(COMPOSE_FILES) up

# pull:
# 	@echo "Pulling docker images..."
# 	docker-compose $(COMPOSE_FILES) pull


# clean:
# 	@echo "Cleaning all services..."
# 	-docker-compose $(COMPOSE_FILES) down -v --remove-orphans

# check-config:
# 	docker-compose $(COMPOSE_FILES) config

# build: $(BUILD_SERVICES)

# $(BUILD_SERVICES):
# 	@echo "Building $(@:build-%=%)..."
# 	make -C $(@:build-%=%-docker) build

# clean-run: stop clean init run

# clean-run-nodaemon: stop clean init run-nodaemon

# $(CLEAN_RUN_SERVICES): clean-run-%: clean init run-%

# init: $(INIT_SERVICES)

# $(INIT_SERVICES):
# 	@echo "Initializing $(@:init-%=%)..."
# #       start service to properly create volume from config
# 	@docker-compose $(COMPOSE_FILES) up --no-start $(@:init-%=%)
# 	@/bin/bash ./bin/init-service.sh $(@:init-%=%)



# backup: $(BACKUP_SERVICES)

# $(BACKUP_SERVICES):
# 	@echo "Backing up mounts of service $(@:backup-%=%)..."
# 	@/bin/bash ./bin/backup-service.sh $(@:backup-%=%)

