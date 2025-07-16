# Makefile

APP_ENV ?= docker

setup-db:
	docker compose exec -e APP_ENV=$(APP_ENV) app ruby db/setup.rb

build:
	docker compose up --build -d

test:
	docker compose exec app bundle exec rspec

console:
	docker compose exec app irb

psql:
	docker compose exec db psql -U johannes -d legal_docs_db

psql-test:
	docker compose exec db psql -U johannes -d legal_docs_test

logs:
	docker compose logs -f

down:
	docker compose down
