require "json"
require "net/http"

module Services
  class EmbedService
    API_URL = ENV["HF_API_URL"]
    API_KEY = ENV["HF_API_KEY"]
    MAX_ENTRIES = 3

    def self.embed(text)
      raise "HF_API_KEY is missing" unless API_KEY

      payload = { inputs: text }

      headers = {
        "Authorization" => "Bearer #{API_KEY}",
        "Content-Type" => "application/json",
      }

      retries = 0

      begin
        uri = URI(API_URL)

        response = Net::HTTP.post(uri, JSON.dump(payload), headers)

        raise "Embedding failed: #{response.code} - #{response.message}" unless response.is_a?(Net::HTTPSuccess)

        # Parse the response body to get the embedding
        body = JSON.parse(response.body)
        embedding = if body.is_a?(Array)
            if body.first.is_a?(Array) && body.first.all? { |v| v.is_a?(Numeric) }
              body.first # [ [ vector ] ]
            elsif body.all? { |v| v.is_a?(Numeric) }
              body       # [ vector ]
            elsif body.first.is_a?(Array) && body.first.first.is_a?(Array)
              body.first.first # [ [ [ vector ] ] ]
            else
              raise "Unexpected embedding structure: #{body.inspect}"
            end
          else
            raise "Unexpected response type from HF API: #{body.inspect}"
          end

        unless embedding.is_a?(Array) && embedding.all? { |v| v.is_a?(Numeric) }
          raise "Invalid embedding format after normalization: #{embedding.inspect}"
        end

        # Convert the embedding to floats
        embedding.map!(&:to_f)

        embedding
      rescue StandardError => e
        retries += 1

        puts "Error embedding text: #{e.message}"

        raise "Failed to generate embedding after #{retries} attempts" unless retries < MAX_ENTRIES

        sleep(1.5 ** retries)
        retry
      end
    end
  end
end
