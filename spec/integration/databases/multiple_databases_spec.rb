# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Databases: multiple databases import" do
  let(:config) do
    Jekyll.configuration(
      "source"      => SOURCE_DIR,
      "destination" => DEST_DIR,
      "collections" => { "articles" => { "output" => true } },
      "notion"      => {
        "databases" => [
          { "id" => "1ae33dd5f3314402948069517fa40ae2" }, # Default to posts
          {
            "id"         => "1ae33dd5f3314402948069517fa40ae2", # Same database to different collection
            "collection" => "articles",
          },
        ],
      }
    )
  end

  let(:site) { Jekyll::Site.new(config) }

  before do
    VCR.use_cassette("notion_database") { site.process }
  end

  it_behaves_like "a collection is renderded correctly", "posts"
  it_behaves_like "a collection is renderded correctly", "articles"
  it_behaves_like "a jekyll collection", "posts"
  it_behaves_like "a jekyll collection", "articles"

  it "imports to both posts and articles collections" do
    expect(site.posts.size).to be > 0
    expect(site.collections["articles"].size).to be > 0
  end

  it "maintains separate collections" do
    post_titles = site.posts.map(&:data).map { |d| d["title"] }
    article_titles = site.collections["articles"].map(&:data).map { |d| d["title"] }

    # Same database imported to different collections should have same content
    expect(post_titles).to match_array(article_titles)
  end

  context "with mixed collections and data import" do
    let(:config) do
      Jekyll.configuration(
        "source"      => SOURCE_DIR,
        "destination" => DEST_DIR,
        "collections" => { "articles" => { "output" => true } },
        "notion"      => {
          "databases" => [
            { "id" => "1ae33dd5f3314402948069517fa40ae2" }, # Default to posts
            {
              "id"         => "1ae33dd5f3314402948069517fa40ae2",
              "collection" => "articles",
            },
            {
              "id"   => "1ae33dd5f3314402948069517fa40ae2",
              "data" => "database_entries",
            },
          ],
        }
      )
    end

    it_behaves_like "a collection is renderded correctly", "posts"
    it_behaves_like "a collection is renderded correctly", "articles"
    it_behaves_like "a jekyll data array", "database_entries"

    it "imports to collections and data simultaneously" do
      expect(site.posts.size).to be > 0
      expect(site.collections["articles"].size).to be > 0
      expect(site.data["database_entries"]).to be_an(Array)
      expect(site.data["database_entries"].size).to be > 0
    end
  end
end
