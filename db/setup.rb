require_relative "connection"

conn = db_connection

# Enable pgvector extension
conn.exec("CREATE EXTENSION IF NOT EXISTS vector;")

# Create documents table
conn.exec <<~SQL
            CREATE TABLE IF NOT EXISTS documents (
              id SERIAL PRIMARY KEY,
              title VARCHAR(255) NOT NULL,
              content TEXT,
              created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            );
          SQL

# Create document_chunks table with embedding column
conn.exec <<~SQL
            CREATE TABLE IF NOT EXISTS document_chunks (
              id SERIAL PRIMARY KEY,
              document_id INTEGER REFERENCES documents(id) ON DELETE CASCADE,
              chunk_number INTEGER NOT NULL,
              content TEXT NOT NULL,
              embedding vector(384),
              created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
              UNIQUE (document_id, chunk_number)
            );
          SQL

puts "✅ Database setup complete with pgvector support."

conn.close
