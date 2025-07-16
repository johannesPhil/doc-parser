require "pg"
require "dotenv/load"

require_relative "config"

def db_connection
  # puts "Connecting to the database with config: #{db}"
  PG.connect(DB_CONFIG.fetch(ENVIRONMENT))
rescue PG::Error => e
  puts "Connection error: #{e.message}"
  exit 1
end
