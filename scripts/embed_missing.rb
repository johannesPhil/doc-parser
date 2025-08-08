require_relative "../db/connection"
require_relative "../app/services/embedding_service"

conn = db_connection()

begin
  rows = conn.exec("SELECT id, content FROM document_chunks WHERE embedding IS NULL ORDER BY id;")

  if rows.ntuples.zero?
    puts "No document chunks with missing embeddings found."

    exit 0
  end

  puts "Found #{rows.ntuples} document chunks with missing embeddings."

  conn.transaction do |transaction|
    rows.each do |row|
      chunk_id = row["id"].to_i
      content = row["content"]

      attempts = 0
      embedding = nil

      begin
        attempts += 1
        embedding = Services::EmbedService.embed(content)
      rescue => e
        puts "Error embedding chunk #{chunk_id}: #{e.message}"
        retry if attempts < 3
        raise "Failed to generate embedding after #{attempts} attempts for chunk ##{chunk_id}"
      end

      transaction.exec_params("UPDATE document_chunks SET embedding = $1 WHERE id = $2", [embedding, chunk_id])
      puts "Updated chunk ##{chunk_id} with new embedding."
    end
  end

  puts "🎯 All missing embeddings have been generated successfully."
rescue PG::Error => e
  puts "Error connecting to the database: #{e.message}"
  exit 1
ensure
  conn.close if conn
end
