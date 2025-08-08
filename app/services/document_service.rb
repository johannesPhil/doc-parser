require_relative "../../db/connection"
require_relative "../../app/services/embedding_service"

module Services
  class DocumentServices
    # def self.save(document)
    #   conn = db_connection()

    #   conn.exec_params("INSERT INTO documents (title, content) VALUES ($1, $2)", [document[:title], document[:content]])

    #   puts "Document #{document[:title]} saved successfully."

    #   conn.close
    # rescue PG::Error => e
    #   puts "Error saving document: #{e.message}"
    # end

    def self.save_chunks(title, chunks)
      conn = db_connection()

      conn.transaction do |transaction|
        timestamp = Time.now.utc
        document = transaction.exec_params("INSERT INTO documents (title,created_at) VALUES ($1, $2) RETURNING id", [title, timestamp])

        document_id = document[0]["id"].to_i

        chunks.each do |chunk|
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

        puts "Successfully saved #{chunks.size} chunks with embeddings for document '#{title}'."
      end
    rescue PG::Error => e
      puts "Error saving chunks: #{e.message}"
      raise
    ensure
      conn.close if conn
    end
  end
end
