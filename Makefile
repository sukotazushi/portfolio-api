DC := docker compose
APP ?= api

# --------------------
# Docker
# --------------------

build:
	$(DC) build

up:
	$(DC) up

up-d:
	$(DC) up -d

down:
	$(DC) down

restart:
	$(DC) down
	$(DC) up

logs:
	$(DC) logs -f --tail=200

ps:
	$(DC) ps

# --------------------
# App
# --------------------

bash:
	$(DC) exec $(APP) bash

# --------------------
# Database (Rails)
# --------------------

db-create:
	$(DC) exec $(APP) bundle exec rails db:create

db-migrate:
	$(DC) exec $(APP) bundle exec rails db:migrate

# STEP指定可（例: make db-rollback STEP=2）
STEP ?= 1
db-rollback:
	$(DC) exec $(APP) bundle exec rails db:rollback STEP=$(STEP)

db-seed:
	$(DC) exec $(APP) bundle exec rails db:seed

# 危険：ローカルDB完全初期化
db-reset:
	@echo "WARNING: This will DROP the database. Continue? (y/N)"
	@read ans; \
	if [ "$$ans" = "y" ] || [ "$$ans" = "Y" ]; then \
	  $(DC) exec $(APP) bundle exec rails db:drop db:create db:migrate db:seed; \
	fi

# --------------------
# RSpec
# --------------------

spec:
	@if [ -z "$(FILE)" ]; then \
	  echo "FILE is required."; \
	  echo "Examples:"; \
	  echo "  make spec FILE=spec/models/user_spec.rb"; \
	  echo "  make spec FILE=spec/models/user_spec.rb:42"; \
	  exit 1; \
	fi
	$(DC) exec $(APP) bundle exec rspec $(FILE)
