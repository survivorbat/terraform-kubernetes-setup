SHELL := /bin/bash

MAKEFLAGS := --no-print-directory --silent

.DEFAULT_GOAL := help

.PHONY := help

help: ## Show the list of commands
	@echo "Please use 'make <target>' where <target> is one of"
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z0-9\._-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

build: ## Build the docker containers
	docker-compose -f src/docker-compose.yaml -p example build
	echo "Build complete!"

up: ## Run the application in docker
	docker-compose -f src/docker-compose.yaml -p example up -d
	echo "All set! Visit http://localhost to view the application, http://localhost:8080 for phpmyadmin"

down: ## Down the application in docker
	docker-compose -f src/docker-compose.yaml -p example down
	echo "Have a nice day."
