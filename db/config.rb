ENVIRONMENT = ENV.fetch("APP_ENV", "development")

DB_CONFIG = {
  "development" => {
    dbname: ENV.fetch("DATABASE_NAME"),
    user: ENV.fetch("DATABASE_USER"),
    password: ENV.fetch("DATABASE_PASSWORD"),
    host: ENV.fetch("DATABASE_HOST"),
    port: ENV.fetch("DATABASE_PORT"),
  },
  "docker" => {
    dbname: ENV.fetch("DATABASE_NAME"),
    user: ENV.fetch("DATABASE_USER"),
    password: ENV.fetch("DATABASE_PASSWORD"),
    host: ENV.fetch("DATABASE_HOST"),
    port: ENV.fetch("DATABASE_PORT"),
  },
  "test" => {
    dbname: ENV.fetch("DATABASE_NAME"),
    user: ENV.fetch("DATABASE_USER"),
    password: ENV.fetch("DATABASE_PASSWORD"),
    host: ENV.fetch("DATABASE_HOST"),
    port: ENV.fetch("DATABASE_PORT"),
  },
}
