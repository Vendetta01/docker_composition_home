
SERVICES := etcd openldap-server phpldapadmin e3w lum nginx-proxy dnsmasq paperless
RUN_SERVICES := $(SERVICES:%=run-%)
CLEAN_RUN_SERVICES := $(SERVICES:%=clean-run-%)
INIT_SERVICES := $(SERVICES:%=init-%)
BUILD_SERVICES := $(SERVICES:%=build-%)
COMPOSE_FILES := -f docker-compose.base.yml $(SERVICES:%=-f services/docker-compose.%.yml)

.PHONY: run clean build clean-run stop $(RUN_SERVICES) $(CLEAN_RUN_SERVICES) $(BUILD_SERVICES) $(INIT_SERVICES) init


run:
	@echo "Running all services..."
	docker-compose $(COMPOSE_FILES) up

$(RUN_SERVICES):
	@echo "Running $(@:run-%=%)..."
	docker-compose $(COMPOSE_FILES) up $(@:run-%=%)

clean:
	@echo "Cleaning all services..."
	-docker-compose $(COMPOSE_FILES) down -v

check-config:
	docker-compose $(COMPOSE_FILES) config

build: $(BUILD_SERVICES)

$(BUILD_SERVICES):
	@echo "Building $(@:build-%=%)..."
	make -C $(@:build-%=%-docker) build

clean-run: stop clean init run

$(CLEAN_RUN_SERVICES): clean-run-%: clean init-% run-%

init: $(INIT_SERVICES)

$(INIT_SERVICES):
	@echo "Initializing $(@:init-%=%)..."
	@./bin/$@.sh || true

stop:
	-docker-compose $(COMPOSE_FILES) down

