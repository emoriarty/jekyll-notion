# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Databases: single database import" do
  let(:config) do
    Jekyll.configuration(
      "source"      => SOURCE_DIR,
      "destination" => DEST_DIR,
      "notion"      => {
        "databases" => [{ "id" => "1ae33dd5f3314402948069517fa40ae2" }], # Test Database
      }
    )
  end

  let(:site) { Jekyll::Site.new(config) }

  before do
    VCR.use_cassette("notion_database") { site.process }
  end

  it_behaves_like "a collection is renderded correctly", "posts"
  it_behaves_like "a jekyll collection", "posts"

  it "imports database entries as posts with correct naming" do
    site.posts.each do |post|
      expect(post.path).to match(%r!_posts/\d{4}-\d{2}-\d{2}-.*.md$!)
    end
  end

  context "with custom collection" do
    let(:config) do
      Jekyll.configuration(
        "source"      => SOURCE_DIR,
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
    it_behaves_like "a jekyll collection", "articles"

    it "imports database entries as articles without date prefix" do
      site.collections["articles"].each do |article|
        expect(article.path).to match(%r!_articles/[^/]+\.md$!)
        expect(article.path).not_to match(%r!\d{4}-\d{2}-\d{2}!)
      end
    end
  end

  context "with data import" do
    let(:config) do
      Jekyll.configuration(
        "source"      => SOURCE_DIR,
        "destination" => DEST_DIR,
        "notion"      => {
          "databases" => [{
            "id"   => "1ae33dd5f3314402948069517fa40ae2",
            "data" => "test_database",
          }],
        }
      )
    end

    it_behaves_like "a jekyll data array", "test_database"

    it "stores all database entries in data object" do
      expect(site.data["test_database"]).to be_an(Array)
      expect(site.data["test_database"].size).to be > 0
    end

    it "contains content property for each entry" do
      site.data["test_database"].each do |entry|
        expect(entry).to have_key("content")
        expect(entry).to have_key("title")
      end
    end
  end
end
