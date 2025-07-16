require_relative "connection"

conn = db_connection

conn.exec <<~SQL
            CREATE TABLE IF NOT EXISTS documents (
              id SERIAL PRIMARY KEY,
              title VARCHAR(255),
              content TEXT,
              created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            );
          SQL

conn.exec <<~SQL
            CREATE TABLE IF NOT EXISTS document_chunks (
              id SERIAL PRIMARY KEY,
              document_id INTEGER REFERENCES documents(id) ON DELETE CASCADE,
              chunk_number INTEGER NOT NULL,
              content TEXT NOT NULL,
              created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
              UNIQUE (document_id, chunk_number)
            );
          SQL

puts "✅ Database setup complete."

conn.close
