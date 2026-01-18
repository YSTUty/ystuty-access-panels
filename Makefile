project_name ?= ystuty_access_panels

base_yml := docker-compose.yml

dc := docker compose -p "$(project_name)"

files_base := -f $(base_yml)

panel_service_pg := pgadmin
panel_service_redis := redisinsight ri-nginx-basicauth

networks := ystuty_network ystuty_access

.DEFAULT_GOAL := help

.PHONY: help ps logs down stop restart pull \
	up up-pgadmin up-redis \
  ensure-networks

help:
	@printf '%s\n' \
	'Targets:' \
	'  up           Start all services' \
	'  up-pgadmin   Start pgadmin only' \
	'  up-redis     Start redisinsight only' \
	'  ps           Show containers' \
	'  pull         Pull images' \
	'  logs         Follow logs (all)' \
	'  down         Stop and remove stack'

ensure-networks:
	@set -e; \
	for n in $(networks); do \
		docker network inspect $$n >/dev/null 2>&1 || docker network create $$n >/dev/null; \
	done

ensure-networks-log:
	@for n in $(networks); do \
			if ! docker network inspect "$$n" >/dev/null 2>&1; then \
					echo "Creating network $$n..."; \
					docker network create "$$n"; \
			else \
					echo "Network $$n already exists"; \
			fi \
	done

ps:
	@$(dc) ps

logs:
	@$(dc) logs -f --tail=200

pull:
	@$(dc) $(files_base) pull

stop:
	@$(dc) stop

restart:
	@$(dc) restart

down:
	@$(dc) $(files_prod_db) down

up: ensure-networks
	@$(dc) $(files_base) up -d

up-pgadmin: ensure-networks
	@$(dc) $(files_base) up -d $(panel_service_pg)

up-redis: ensure-networks
	@$(dc) $(files_base) up -d $(panel_service_redis)

# up-pgadmin: ensure-networks prepare-pgadmin
# 	@$(dc) $(files_base) up -d $(panel_services)

# prepare-pgadmin:
# 	@mkdir -p ./pgadmin-data
# 	@sudo chown -R 5050:5050 ./pgadmin-data
