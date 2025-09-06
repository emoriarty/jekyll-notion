# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Databases: preserve existing files" do
  let(:config) do
    Jekyll.configuration(
      "source"      => SOURCE_DIR_2, # Contains existing posts
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

  it "imports database and generates documents" do
    site.posts.each do |document|
      if document.title == "Page 1"
        expect(document.output).to eq("<p>This post is a clone from the notion database</p>\n")
      elsif document.title == "My Post"
        expect(document.output).to eq("<p>Wow, what an amazing article!</p>\n")
      else
        expect_to_match_document(document)
      end
    end
  end

  it_behaves_like "a jekyll collection with existing posts", "posts"

  it "preserves existing posts from filesystem" do
    # Files present in the source dir should be preserved
    existing_post_1 = site.posts.find { |p| p.path.end_with?("2022-01-01-my-post.md") }
    existing_post_2 = site.posts.find { |p| p.path.end_with?("2022-01-23-page-1.md") }

    expect(existing_post_1).to be_an_instance_of(Jekyll::Document)
    expect(existing_post_2).to be_an_instance_of(Jekyll::Document)
  end

  it "combines filesystem posts and Notion database entries" do
    # Should have both existing filesystem posts and imported Notion entries
    expect(site.posts.size).to be >= 8 # 7 from database + at least 1 from filesystem
  end

  it "does not create duplicate files for existing Notion entries" do
    # If a file with the same name exists, it should not create a duplicate
    # This tests the file_exists? check in the Collection generator

    # Count posts with similar names - shouldn't have exact duplicates
    post_paths = site.posts.map(&:path)
    unique_basenames = post_paths.map { |p| File.basename(p) }.uniq

    expect(unique_basenames.size).to eq(post_paths.size)
  end

  context "with custom collection" do
    let(:config) do
      Jekyll.configuration(
        "source"      => SOURCE_DIR_2,
        "destination" => DEST_DIR,
        "collections" => { "articles" => { "output" => true } },
        "notion"      => {
          "databases" => [{
            "id"         => "1ae33dd5f3314402948069517fa40ae2",
            "collection" => "articles",
          }],
        }
      )
    end

    it_behaves_like "a collection is renderded correctly", "articles"

    it "creates articles collection without affecting existing posts" do
      expect(site.collections["articles"].size).to be > 0
      expect(site.posts.size).to eq(2) # Only the existing filesystem posts
    end
  end
end
