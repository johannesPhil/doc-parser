require "spec_helper"
require_relative "../../app/services/document_service"

RSpec.describe Services::DocumentServices do
  describe ".save_chunks" do
    it "saves document chunks to the database" do
      chunks = [
        { chunk_number: 1, content: "This is the first chunk." },
        { chunk_number: 2, content: "This is the second chunk." },
      ]

      described_class.save_chunks("Test Document", chunks)

      conn = db_connection
      doc_result = conn.exec("SELECT * FROM documents ORDER BY id DESC LIMIT 1")
      document_id = doc_result[0]["id"].to_i

      chunks_result = conn.exec_params("SELECT * FROM document_chunks WHERE document_id = $1", [document_id])

      expect(doc_result.ntuples).to eq(1)
      expect(chunks_result.ntuples).to eq(2)

      conn.close
    end
  end
end
