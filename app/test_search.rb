require_relative "services/search_service"

query = ARGV[0]
raise "No query provided. Usage: ruby test_search.rb 'your search query'" if query.nil? || query.strip.empty?

puts "Starting search for query: '#{query}'"

begin
  results = Services::SearchService.search(query, limit: 5)
  puts "Search results for '#{query}':"
  counter = 0
  results.each do |res|
    counter += 1
    puts "\n#{counter}. \n:Source: #{res[:title]}\n"
    puts "Score: #{res[:score]}\n"
    puts "Similarity: #{res[:similarity]}\n"
    puts "Content: #{res[:content][0..1000] + (res[:content].size > 1000 ? "..." : "")}"
  end
rescue StandardError => e
  puts "An error occurred during search: #{e.message} - #{e.backtrace.join("\n")}"
end
