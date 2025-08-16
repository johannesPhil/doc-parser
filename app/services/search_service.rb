require "json"
require "net/http"
require_relative "embedding_service"
require_relative "../../db/connection"

module Services
  # class Services::SearchService
  class SearchService
    MAX_ENTRIES = 3

    def self.search(query, limit: 5)
      embedding = Services::EmbedService.embed(query)

      puts "Generated embedding for query: #{embedding.inspect}"

      conn = db_connection

      sql_query = <<~SQL
          SELECT dc.id,
                dc.content,
                dc.embedding,
                d.title,
                1 - (dc.embedding <=>$1::vector) AS similarity FROM document_chunks dc
        JOIN documents d ON dc.document_id = d.id
        ORDER BY dc.embedding <=> $1::vector
        LIMIT $2;
      SQL

      search_result = conn.exec_params(sql_query, [embedding, limit])

      search_result.map do |row|
        {
          id: row["id"].to_i,
          content: row["content"],
          title: row["title"],
          similarity: row["similarity"].to_f,
        }
      end
    end
  end
end
