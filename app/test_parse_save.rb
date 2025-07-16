require_relative "parsers/document_parser"
require_relative "services/document_service"

file_path = ARGV[0]

unless File.exist?(file_path)
  puts "No file provided"
  exit 1
end

title = File.basename(file_path, ".*")

chunks = Parsers::DocumentParser.parse_into_chunk(file_path, chunk_size: 1000, verbose: true)

if chunks.empty?
  puts "No chunks generated from file: #{file_path}"
  exit 1
end
Services::DocumentServices.save_chunks(title, chunks)
