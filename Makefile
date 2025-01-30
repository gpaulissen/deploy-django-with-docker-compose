UID                    := $(shell id -u)
APP_DIR                := ./app
DATA_DIR               := ./data
DOCKER_COMPOSE         := docker-compose
LANG                   := C

PLATFORM               := linux/$(shell uname -m)
UID                    := $(shell id -u)
GID                    := $(shell id -g)

# export these variables to the environment when running commands
export UID GID

# Do not print help for .env files
help: ## This help.
	@for f in $(MAKEFILE_LIST); do case "$$f" in *Makefile*) ;; *) continue;; esac; echo ""; echo "=== The targets in file $$f ==="; sed -nr 's/^([0-9a-zA-Z._-]+):.+##(.+)/\1:\t\2/; /.+:\t.+/p' $$f | { while read line; do t=$$(echo $$line | cut -d ':' -f 1); h=$$(echo $$line | cut -d ':' -f 2); printf "%-30s:%s\n" "$$t" "$$h"; done; }; done

init: build ## Initialize the environment
	-chmod -R 750 $(APP_DIR)
	-chmod -R 750 $(DATA_DIR)

build-app: ## Build the (dev) Docker image
	$(DOCKER_COMPOSE) build

create-app: build-app  ## Create the application
	$(DOCKER_COMPOSE) run --rm app sh -c "django-admin startproject app ."

create-model: build-app ## Create the model
	$(DOCKER_COMPOSE) run --rm app sh -c "python manage.py startapp core"

makemigrations: build-app ## Make migrations
	$(DOCKER_COMPOSE) run --rm app sh -c "python manage.py makemigrations"

createsuperuser: build-app ## Create (dev) superuser
	$(DOCKER_COMPOSE) run --rm app sh -c "python manage.py createsuperuser"

stop-app: ## Stop (dev) app
	-$(DOCKER_COMPOSE) down --volumes --remove-orphans

start-app: stop-app build-app ## Start (dev) app
	$(DOCKER_COMPOSE) up -d

## Deploy (prod) section

create-model-deploy: build-app-deploy ## Create the (prod) model
	$(DOCKER_COMPOSE) -f docker-compose-deploy.yml run --rm app sh -c "python manage.py startapp core"

makemigrations-deploy: build-app-deploy ## Make (prod) migrations
	$(DOCKER_COMPOSE) -f docker-compose-deploy.yml run --rm app sh -c "python manage.py makemigrations"

migrate-deploy: build-app-deploy ## Migrate (prod)
	$(DOCKER_COMPOSE) -f docker-compose-deploy.yml run --rm app sh -c "python manage.py migrate"

createsuperuser-deploy: build-app-deploy ## Create (prod) superuser
	$(DOCKER_COMPOSE) -f docker-compose-deploy.yml run --rm app sh -c "python manage.py createsuperuser"

stop-app-deploy: ## Stop the (prod) Docker image
	-$(DOCKER_COMPOSE) -f docker-compose-deploy.yml down --volumes --remove-orphans

build-app-deploy: ## Build the (prod) Docker image
	$(DOCKER_COMPOSE) -f docker-compose-deploy.yml build

start-app-deploy: stop-app-deploy build-app-deploy ## Start the (prod) Docker image
	$(DOCKER_COMPOSE) -f docker-compose-deploy.yml up -d
