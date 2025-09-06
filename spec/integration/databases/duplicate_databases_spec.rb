# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Databases: duplicate database handling" do
  let(:config) do
    Jekyll.configuration(
      "source"      => SOURCE_DIR,
      "destination" => DEST_DIR,
      "notion"      => {
        "databases" => [
          { "id" => "1ae33dd5f3314402948069517fa40ae2" },
          { "id" => "1ae33dd5f3314402948069517fa40ae2" }, # Duplicate ID
          { "id" => "1ae33dd5f3314402948069517fa40ae2" }, # Another duplicate
        ],
      }
    )
  end

  let(:site) { Jekyll::Site.new(config) }

  before do
    allow(Jekyll.logger).to receive(:warn)
    VCR.use_cassette("notion_database") { site.process }
  end

  # NOTE: Currently the system doesn't prevent duplicate database processing
  # Unlike pages which have duplicate detection, databases can be processed multiple times
  # This test documents the current behavior

  it "processes all database configurations" do
    # Each database configuration is processed independently
    # This means the same database could be imported multiple times
    expect(site.posts.size).to be > 0
  end

  it "does not warn about duplicate databases" do
    # Unlike pages, databases don't currently have duplicate detection
    expect(Jekyll.logger).not_to have_received(:warn)
      .with("Jekyll Notion:", %r!Duplicate!)
  end

  context "with different configurations for same database" do
    let(:config) do
      Jekyll.configuration(
        "source"      => SOURCE_DIR,
        "destination" => DEST_DIR,
        "collections" => { "articles" => { "output" => true } },
        "notion"      => {
          "databases" => [
            {
              "id"     => "1ae33dd5f3314402948069517fa40ae2",
              "filter" => { "property" => "Select", "select" => { "equals" => "select1" } },
            },
            {
              "id"         => "1ae33dd5f3314402948069517fa40ae2", # Same ID
              "collection" => "articles",
            },
            {
              "id"   => "1ae33dd5f3314402948069517fa40ae2", # Same ID
              "data" => "database_content",
            },
          ],
        }
      )
    end

    it "processes same database with different configurations" do
      expect(site.posts.size).to be > 0
      expect(site.collections["articles"].size).to be > 0
      expect(site.data["database_content"]).to be_an(Array)
    end

    it "allows importing same database to different targets" do
      # This is a legitimate use case - importing same database to multiple collections/data
      post_titles = site.posts.map { |p| p.data["title"] }
      article_titles = site.collections["articles"].map { |p| p.data["title"] }
      data_titles = site.data["database_content"].map { |p| p["title"] }

      expect(post_titles).not_to be_empty
      expect(article_titles).not_to be_empty
      expect(data_titles).not_to be_empty
    end
  end
end
