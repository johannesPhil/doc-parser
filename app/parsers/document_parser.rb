require "pdf-reader"

module Parsers
  class DocumentParser
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

      # Split into paragraphs — multiple newlines as separator
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
  end
end
