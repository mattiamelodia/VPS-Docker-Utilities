# Function: Docker Rebuild
# [execute: down, remove, pull, build, up]
# $(call docker_rebuild,"stack_name")
define docker_rebuild
	docker compose -p $(1) --env-file docker/$(1)/.env -f docker/$(1)/docker-compose.yml down && \
	docker compose -p $(1) --env-file docker/$(1)/.env -f docker/$(1)/docker-compose.yml rm -f && \
	docker compose -p $(1) --env-file docker/$(1)/.env -f docker/$(1)/docker-compose.yml pull && \
	docker compose -p $(1) --env-file docker/$(1)/.env -f docker/$(1)/docker-compose.yml build --no-cache && \
	docker compose -p $(1) --env-file docker/$(1)/.env -f docker/$(1)/docker-compose.yml up -d
endef

# Function: Docker Remove (stops and removes containers)
# [execute: down, remove]
# $(call docker_remove,"stack_name")
define docker_remove
	docker compose -p $(1) --env-file docker/$(1)/.env -f docker/$(1)/docker-compose.yml down && \
	docker compose -p $(1) --env-file docker/$(1)/.env -f docker/$(1)/docker-compose.yml rm -f
endef

# Function: Docker Stop
# [execute: stop]
# $(call docker_stop,"stack_name")
define docker_stop
	docker compose -p $(1) --env-file docker/$(1)/.env -f docker/$(1)/docker-compose.yml stop
endef

# Function: Docker Start (brings up existing containers or starts new ones without rebuilding)
# [execute: up -d]
# $(call docker_start,"stack_name")
define docker_start
	docker compose -p $(1) --env-file docker/$(1)/.env -f docker/$(1)/docker-compose.yml up -d
endef

# Function: Docker Clean (stops, removes containers and associated volumes)
# [execute: down -v]
# $(call docker_clean,"stack_name")
define docker_clean
	docker compose -p $(1) --env-file docker/$(1)/.env -f docker/$(1)/docker-compose.yml down -v
endef

# Initialization
init:
	docker network create --driver bridge reverse-proxy || true # Added '|| true' for robustness

# General target for individual stack operations
.PHONY: remove stop start clean restart

# Remove Stack (stops and removes containers for a specific stack)
remove:
	@if [ -z "$(stack)" ]; then echo "usage: make remove stack=<stack_name>"; exit 1; fi
	$(call docker_remove,$(stack))

# Stop Stack (stops containers for a specific stack)
stop:
	@if [ -z "$(stack)" ]; then echo "usage: make stop stack=<stack_name>"; exit 1; fi
	$(call docker_stop,$(stack))

# Start Stack (starts containers for a specific stack)
start:
	@if [ -z "$(stack)" ]; then echo "usage: make start stack=<stack_name>"; exit 1; fi
	$(call docker_start,$(stack))

# Restart Stack (stops then starts containers for a specific stack)
restart:
	@if [ -z "$(stack)" ]; then echo "usage: make restart stack=<stack_name>"; exit 1; fi
	$(call docker_stop,$(stack))
	$(call docker_start,$(stack))

# Clean Stack (stops, removes containers and volumes for a specific stack)
clean:
	@if [ -z "$(stack)" ]; then echo "usage: make clean stack=<stack_name>"; exit 1; fi
	$(call docker_clean,$(stack))

# Individual Service Targets (Rebuild) - Remain unchanged
# Portainer
portainer:
	docker volume create portainer_data || true
	$(call docker_rebuild,"portainer")

# NGINX Proxy Manager
nginxpm:
	docker volume create nginxpm_data || true
	docker volume create nginxpm_letsencrypt || true
	$(call docker_rebuild,"nginxpm")

# Gotify
gotify:
	docker volume create gotify_data || true
	$(call docker_rebuild,"gotify")

# WatchTower
watchtower:
	$(call docker_rebuild,"watchtower")

# IT Tools
it-tools:
	$(call docker_rebuild,"it-tools")

# Glances
glances:
	$(call docker_rebuild,"glances")

# Whatsapp API
whatsapp-api:
	docker volume create evolution_api_data || true
	docker volume create mongodb_whatsapp_data || true
	$(call docker_rebuild,"whatsapp-api")

# ALL: Group targets

# ALL: Start all utility services (rebuilds and starts all)
all: init portainer nginxpm gotify watchtower it-tools glances

# ALL: Stop all utility services
stop_all:
	$(call docker_stop,"portainer")
	$(call docker_stop,"nginxpm")
	$(call docker_stop,"gotify")
	$(call docker_stop,"watchtower")
	$(call docker_stop,"it-tools")
	$(call docker_stop,"glances")

# ALL: Start all utility services (without rebuilding)
start_all:
	$(call docker_start,"portainer")
	$(call docker_start,"nginxpm")
	$(call docker_start,"gotify")
	$(call docker_start,"watchtower")
	$(call docker_start,"it-tools")
	$(call docker_start,"glances")

# ALL: Restart all utility services
restart_all:
	$(call docker_stop,"portainer")
	$(call docker_stop,"nginxpm")
	$(call docker_stop,"gotify")
	$(call docker_stop,"watchtower")
	$(call docker_stop,"it-tools")
	$(call docker_stop,"glances")
	$(call docker_start,"portainer")
	$(call docker_start,"nginxpm")
	$(call docker_start,"gotify")
	$(call docker_start,"watchtower")
	$(call docker_start,"it-tools")
	$(call docker_start,"glances")

# ALL: Clean all utility services (stops, removes containers and volumes)
clean_all:
	$(call docker_clean,"portainer")
	$(call docker_clean,"nginxpm")
	$(call docker_clean,"gotify")
	$(call docker_clean,"watchtower")
	$(call docker_clean,"it-tools")
	$(call docker_clean,"glances")