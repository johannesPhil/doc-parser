require "json"
require "net/http"

module Services
  class EmbedService
    API_URL = ENV["HF_API_URL"]
    API_KEY = ENV["HF_API_KEY"]
    MAX_ENTRIES = 3

    def self.embed(text)
      raise "HF_API_KEY is missing" unless API_KEY

      payload = [text]

      headers = {
        "Authorization" => "Bearer #{API_KEY}",
        "Content-Type" => "application/json",
      }

      retries = 0

      begin
        uri = URI(API_URL)
        response = Net::HTTP.post(uri, JSON.dump(payload), headers)

        raise "Embedding failed: #{response.code} - #{response.message}" unless response.is_a?(Net::HTTPSuccess)

        #Parse the response body to get the embedding
        embedding = JSON.parse(response.body).first

        raise "Invalid Embedding" unless embedding.is_a?(Array)

        #Convert the embedding to floats
        embedding.map!(&:to_f)

        embedding
      rescue => e
        retries += 1

        puts "Error embedding text: #{e.message}"
        if retries < MAX_ENTRIES
          sleep(1.5 ** retries)
          retry
        else
          raise "Failed to generate embedding after #{retries} attempts"
        end
      end
    end
  end
end
