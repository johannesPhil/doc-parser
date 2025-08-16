require "pdf-reader"
require "open3"

module Parsers
  class DocumentParser

    # Keep a sensible default based on our earlier discussion
    DEFAULT_MAX_TOKENS = 250
    DEFAULT_OVERLAP = 50
    CHUNK_SIZE = 1000

    def self.parse_into_chunk(file_path, chunk_size: CHUNK_SIZE, verbose: false)
      unless File.readable?(file_path)
        raise ArgumentError, "File not readable: #{file_path}"
      end

      format = File.extname(file_path).downcase

      content = if format == ".pdf"
          reader = PDF::Reader.new(file_path)
          content = reader.pages.map(&:text).join("\n\n")
        else
          content = File.read(file_path)
        end

      raise ArgumentError, "File is empty: #{file_path}" if content.strip.empty?

      # Try token-based chunking via the Python helper
      begin
        token_chunks = token_chunks_for(content, max_tokens: DEFAULT_MAX_TOKENS, overlap: DEFAULT_OVERLAP)
        if token_chunks && !token_chunks.empty?
          chunks = []
          token_chunks.each_with_index do |chunk_text, idx|
            chunks << { chunk_number: idx + 1, content: chunk_text.strip }
          end

          puts "Total token-based chunks created: #{chunks.size}" if verbose
          chunks.each do |chunk|
            puts "Chunk ##{chunk[:chunk_number]}: #{chunk[:content][0..120].gsub("\n", " ")}..." if verbose
            yield chunk if block_given?
          end
          return chunks
        end
      rescue => e
        # If the token-chunker fails, log and fall back to old method
        warn "Token chunker failed: #{e.message}. Falling back to character-based chunking."
      end

      # -----------------------
      # Fallback: paragraph/character-based chunking
      # -----------------------

      paragraphs = content.split(/\n{2,}/).map(&:strip).reject(&:empty?)

      chunks = []
      current_chunk = ""
      chunk_number = 1

      paragraphs.each do |paragraph|
        if (current_chunk.length + paragraph.length + 2) <= chunk_size
          # Merge with previous chunk using double newline
          current_chunk += (current_chunk.empty? ? "" : "\n\n") + paragraph
        else
          # Save the current chunk
          unless current_chunk.empty?
            chunks << { chunk_number: chunk_number, content: current_chunk }
            chunk_number += 1
          end

          if paragraph.length > chunk_size
            # Split long paragraph into multiple subchunks
            paragraph.scan(/.{1,#{chunk_size}}/m) do |subchunk|
              chunks << { chunk_number: chunk_number, content: subchunk.strip }
              chunk_number += 1
            end
            current_chunk = ""
          else
            current_chunk = paragraph
          end
        end
      end

      # Push any remaining chunk
      unless current_chunk.empty?
        chunks << { chunk_number: chunk_number, content: current_chunk }
      end

      puts "Total chunks created: #{chunks.size}" if verbose

      chunks.each do |chunk|
        puts "Chunk ##{chunk[:chunk_number]}: #{chunk[:content][0..29].gsub("\n", " ")}..." if verbose
        yield chunk if block_given?
      end

      chunks
    end

    def self.token_chunks_for(text, max_tokens:, overlap:)
      # Build command
      script = File.expand_path("../../tools/token_chunk.py", __dir__)
      unless File.exist?(script)
        raise "Token chunker script not found at #{script}"
      end

      cmd = ["python3", script, max_tokens.to_s, overlap.to_s]
      stdout_str, stderr_str, status = Open3.capture3(*cmd, stdin_data: text)

      unless status.success?
        raise "Token chunker failed (status=#{status.exitstatus}): #{stderr_str.strip}"
      end

      JSON.parse(stdout_str) # returns array of strings
    end
  end
end
