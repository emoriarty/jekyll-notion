# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Databases: edge cases and error handling" do
  context "with posts collection containing date-based filenames" do
    let(:config) do
      Jekyll.configuration(
        "source"      => SOURCE_DIR,
        "destination" => DEST_DIR,
        "notion"      => {
          "databases" => [{
            "id" => "1ae33dd5f3314402948069517fa40ae2",
          }],
        }
      )
    end

    let(:site) { Jekyll::Site.new(config) }

    before do
      VCR.use_cassette("notion_database") { site.process }
    end

    it "generates date-prefixed filenames for posts" do
      site.posts.each do |post|
        expect(post.path).to match(%r!_posts/\d{4}-\d{2}-\d{2}-.+\.md$!)
      end
    end

    it "uses page date property when available" do
      # Find a post that has a specific date property
      dated_post = site.posts.find { |p| p.data["title"] == "Page 1" }
      expect(dated_post.path).to match(%r!2022-01-23-page-1\.md$!)
    end

    it "falls back to created_time when date property is missing" do
      # Find a post without explicit date property
      created_time_post = site.posts.find { |p| p.data["title"] == "tables" }
      expect(created_time_post.path).to match(%r!2022-09-17-tables\.md$!)
    end
  end

  context "with custom collection using non-date filenames" do
    let(:config) do
      Jekyll.configuration(
        "source"      => SOURCE_DIR,
        "destination" => DEST_DIR,
        "collections" => { "docs" => { "output" => true } },
        "notion"      => {
          "databases" => [{
            "id"         => "1ae33dd5f3314402948069517fa40ae2",
            "collection" => "docs",
          }],
        }
      )
    end

    let(:site) { Jekyll::Site.new(config) }

    before do
      VCR.use_cassette("notion_database") { site.process }
    end

    it "generates non-date filenames for custom collections" do
      site.collections["docs"].each do |doc|
        expect(doc.path).to match(%r!_docs/[^/]+\.md$!)
        expect(doc.path).not_to match(%r!\d{4}-\d{2}-\d{2}!)
      end
    end

    it "uses slugified titles for filenames" do
      # Find a document with special characters in title
      special_doc = site.collections["docs"].find do |d|
        d.data["title"].include?('"') || d.data["title"].include?("'") || d.data["title"].include?(":")
      end

      if special_doc
        # Should be slugified (no quotes, colons, etc.)
        expect(special_doc.path).not_to include('"')
        expect(special_doc.path).not_to include("'")
        expect(special_doc.path).not_to include(":")
      end
    end
  end
end
