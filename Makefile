
SERVICES := base admin paperless budget metabase home-assistant simple-expenses


RUN_SERVICES := $(SERVICES:%=run-%)
RUN_SERVICES_DEBUG := $(SERVICES:%=debug-%)
STOP_SERVICES := $(SERVICES:%=stop-%)
CLEAN_SERVICES := $(SERVICES:%=clean-%)
CLEAN_RUN_SERVICES := $(SERVICES:%=clean-run-%)
CLEAN_DEBUG_SERVICES := $(SERVICES:%=clean-debug-%)
INIT_SERVICES := $(SERVICES:%=init-%)
BUILD_SERVICES := $(SERVICES:%=build-%)
BACKUP_SERVICES := $(SERVICES:%=backup-%)
COMPOSE_FILES_BASE := -f docker-compose.base.yml -f services/docker-compose.base.yml
COMPOSE_FILES_ALL := $(COMPOSE_FILES_BASE) $(SERVICES:%=-f services/docker-compose.%.yml)

.PHONY: $(RUN_SERVICES) $(RUN_SERVICES_DEBUG) $(STOP_SERVICES) $(CLEAN_SERVICES) \
	$(INIT_SERVICES) $(CLEAN_RUN_SERVICES) $(BACKUP_SERVICES)stop-all clean-all \
	init-all run-all debug-all clean-run-all clean-debug-all backup-all

$(RUN_SERVICES):
	@echo "Running $(@:run-%=%)..."
	docker-compose $(COMPOSE_FILES_BASE) -f services/docker-compose.$(@:run-%=%).yml up -d

$(RUN_SERVICES_DEBUG):
	@echo "Debugging $(@:debug-%=%)..."
	docker-compose $(COMPOSE_FILES_BASE) -f services/docker-compose.$(@:debug-%=%).yml up

$(STOP_SERVICES):
	-docker-compose $(COMPOSE_FILES_BASE) -f services/docker-compose.$(@:stop-%=%).yml down

$(CLEAN_SERVICES):
	@echo "Cleaning $(@:clean-%=%)..."
	-docker-compose $(COMPOSE_FILES_BASE) -f services/docker-compose.$(@:clean-%=%).yml down -v

$(INIT_SERVICES):
	@echo "Initializing $(@:init-%=%)..."
#	start service to properly create volume from config
	@docker-compose $(COMPOSE_FILES_BASE) -f services/docker-compose.$(@:init-%=%).yml up --no-start
	@docker-compose $(COMPOSE_FILES_BASE) -f services/docker-compose.$(@:init-%=%).yml down
	@/bin/bash ./bin/init-service.sh services/docker-compose.$(@:init-%=%).yml

$(CLEAN_RUN_SERVICES): clean-run-%: clean-% init-% run-%

$(CLEAN_DEBUG_SERVICES): clean-debug-%: clean-% init-% debug-%

$(BACKUP_SERVICES):
	@echo "Backing up mounts of service $(@:backup-%=%)..."
	@/bin/bash ./bin/backup-service.sh services/docker-compose.$(@:backup-%=%).yml



stop-all:
	-docker-compose $(COMPOSE_FILES_ALL) down

clean-all:
	@echo "Cleaning all services..."
	-docker-compose $(COMPOSE_FILES_ALL) down -v --remove-orphans

init-all: $(INIT_SERVICES)

run-all:
	@echo "Running all services..."
	docker-compose $(COMPOSE_FILES_ALL) up -d

debug-all:
	@echo "Debugging all services..."
	docker-compose $(COMPOSE_FILES_ALL) up

clean-run-all: clean-all init-all run-all

clean-debug-all: clean-all init-all debug-all

backup-all: $(BACKUP_SERVICES)

check-config:
	@echo "Checking configuration yamls..."
	docker-compose $(COMPOSE_FILES_ALL) config
