require_relative "../../db/connection"
require_relative "../../app/services/embedding_service"

module Services
  # DocumentServices is responsible for saving document chunks and their embeddings to the database.
  class DocumentServices
    def self.save_chunks(title, chunks)
      conn = db_connection()

      conn.transaction do |transaction|
        timestamp = Time.now.utc
        document = transaction.exec_params("INSERT INTO documents (title,created_at) VALUES ($1, $2) RETURNING id", [title, timestamp])

        document_id = document[0]["id"].to_i

        valid_chunks = chunks.reject { |chunk| chunk[:content].nil? || chunk[:content].strip.empty? }

        valid_chunks.each do |chunk|
          embedding = nil
          attempts = 0

          begin
            attempts += 1
            embedding = Services::EmbedService.embed(chunk[:content])
          rescue => e
            puts "Error embedding chunk #{chunk[:chunk_number]}: #{e.message}"
            retry if attempts < 3
            raise "Failed to generate embedding after #{attempts} attempts for chunk ##{chunk[:chunk_number]}"
          end

          transaction.exec_params("INSERT INTO document_chunks (document_id,chunk_number,content,embedding,created_at) VALUES ($1,$2,$3,$4,$5)", [document_id, chunk[:chunk_number], chunk[:content], embedding, timestamp])
        end

        puts "Successfully saved #{valid_chunks.size} chunks with embeddings for document '#{title}'."
      end
    rescue PG::Error => e
      puts "Error saving chunks: #{e.message}"
      raise
    ensure
      conn.close if conn
    end
  end
end
