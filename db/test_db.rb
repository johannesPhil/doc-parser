require "dotenv/load"
require_relative "../db/connection"
require_relative "../db/setup"

conn = db_connection()
result = conn.exec("SELECT NOW()")

puts "Current DB Time:#{result[0]["now"]}"

conn.close if conn
puts "Connection closed."
