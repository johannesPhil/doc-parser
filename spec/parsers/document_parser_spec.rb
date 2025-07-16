require "spec_helper"
require "tempfile"
require_relative "../../app/parsers/document_parser"

RSpec.describe Parsers::DocumentParser do
  describe ".parse_into_chunk" do
    let(:chunk_size) { 1000 }

    context "when the file is readable" do
      it "returns an array of chunks" do
        Tempfile.create("test.txt") do |tempfile|
          tempfile.write("Just a test file.")
          tempfile.rewind

          chunks = described_class.parse_into_chunk(tempfile.path, chunk_size: chunk_size)
          expect(chunks).to be_an(Array)
          expect(chunks.size).to be > 0
        end
      end
    end

    context "when the file is not readable" do
      it "raises an ArgumentError" do
        expect {
          described_class.parse_into_chunk("non_existent_file.txt", chunk_size: chunk_size)
        }.to raise_error(ArgumentError, /File not readable/)
      end
    end

    context "when the file is empty" do
      it "raises an ArgumentError" do
        Tempfile.create("empty_file_path.txt") do |file|
          file.write("")
          file.rewind
          expect {
            described_class.parse_into_chunk(file.path, chunk_size: chunk_size)
          }.to raise_error(ArgumentError, /File is empty/)
        end
      end
    end

    context "when the content exceeds chunk size" do
      it "splits long paragraphs into multiple subchunks" do
        Tempfile.create("long_paragraph.txt") do |file|
          file.write("a" * (chunk_size + 100)) # Create a long paragraph
          file.rewind
          chunks = described_class.parse_into_chunk(file.path, chunk_size: chunk_size)
          expect(chunks.size).to be > 1
        end
      end
    end

    context "when verbose mode is enabled" do
      it "prints the total number of chunks created" do
        Tempfile.create("verbose_test.txt") do |file|
          file.write("Just a test file.")
          file.rewind

          expect {
            described_class.parse_into_chunk(file.path, chunk_size: chunk_size, verbose: true)
          }.to output(/Total chunks created:/).to_stdout
        end
      end
    end
  end
end
