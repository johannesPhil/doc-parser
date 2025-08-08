# Makefile

APP_ENV ?= docker

setup-db:
	docker compose exec -e APP_ENV=$(APP_ENV) app sh -c '\
	  until pg_isready -h "$$DATABASE_HOST" -p "$$DATABASE_PORT" -U "$$DATABASE_USER"; do \
	    echo "Waiting for database..."; \
	    sleep 1; \
	  done && ruby db/setup.rb'

build:
	docker compose up --build -d

test:
	docker compose --env-file .env.test exec app bundle exec rspec

console:
	docker compose exec app irb

psql:
	docker compose exec db psql -U johannes -d legal_docs_db

psql-test:
	docker compose exec db psql -U johannes -d legal_docs_test

parse-save:
	docker compose exec app bundle exec ruby app/test_parse_save.rb $(file)


embed-missing:
	docker compose exec app bundle exec ruby scripts/embed_missing.rb



logs:
	docker compose logs -f

up:
	docker compose up -d

build:
	docker compose up --build -d

down:
	docker compose down
down-hard:
	docker compose down -v
