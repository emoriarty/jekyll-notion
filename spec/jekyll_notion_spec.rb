# frozen_string_literal: true

require "spec_helper"
require "support/page"
require "support/page_data"
require "support/collection"

describe(JekyllNotion) do
  let(:source_dir) { SOURCE_DIR }
  let(:config) do
    Jekyll.configuration({
      "full_rebuild" => true,
      "source"       => source_dir,
      "destination"  => dest_dir,
      "show_drafts"  => false,
      "url"          => "http://example.org",
      "name"         => "My site",
      "author"       => {
        "name" => "Professor Moriarty",
      },
      "collections"  => collections,
      "notion"       => notion_config,
    })
  end
  let(:collections) { nil }
  let(:notion_config) { nil }
  let(:site) { Jekyll::Site.new(config) }

  before do
    allow(Jekyll.logger).to receive(:info)
    allow(Jekyll.logger).to receive(:warn)
  end

  describe "configuration" do
    before do
      allow(Notion::Client).to receive(:new).and_call_original
    end

    context "when no configuration is provided" do
      it "does not create an instance of Notion::Client" do
        expect(Notion::Client).not_to have_received(:new)
      end
    end

    context "when the databases property is nil" do
      let(:notion_config) { { "databases" => nil } }

      it "does not create a collection" do
        expect_any_instance_of(Notion::Client).not_to receive(:database_query)

        VCR.use_cassette("notion_database_empty") { site.process }
      end
    end

    context "when the databases property id is nil" do
      let(:notion_config) { { "databases" => [{ "id" => nil }] } }

      it "does not create a collection" do
        expect_any_instance_of(Notion::Client).not_to receive(:database_query)

        VCR.use_cassette("notion_database_empty") { site.process }
      end
    end
  end

  context "when declaring a notion page" do
    before do
      VCR.use_cassette("notion_page") { site.process }
    end

    let(:notion_config) do
      {
        "pages" => [{
          "id" => "9dc17c9c-9d2e-469d-bbf0-f9648f3288d3",
        }],
      }
    end

    it_behaves_like "a jekyll page"

    context "when site is processed a second time" do
      before do
        VCR.use_cassette("notion_page") { site.process }
      end

      it "pages is not empty" do
        expect(site.pages).not_to be_empty
      end
    end

    context "when the data option is set" do
      let(:notion_config) do
        {
          "pages" => [{
            "id"   => "9dc17c9c-9d2e-469d-bbf0-f9648f3288d3",
            "data" => "page",
          }],
        }
      end

      it_behaves_like "a jekyll data object", "page"
    end
  end

  context "when multiple pages are declared" do
    before do
      VCR.use_cassette("notion_page") { site.process }
    end

    let(:notion_config) do
      {
        "pages" => [{
          "id" => "9dc17c9c-9d2e-469d-bbf0-f9648f3288d3",
        }, {
          "id" => "9dc17c9c-9d2e-469d-bbf0-f9648f3288d3",
        },],
      }
    end

    it_behaves_like "a jekyll page"
  end

  context "when a notion database is declared" do
    before do
      VCR.use_cassette("notion_database") { site.process }
    end

    context "with the default collection" do
      let(:notion_config) do
        {
          "databases" => [{
            "id" => "1ae33dd5f3314402948069517fa40ae2",
          }],
        }
      end

      it_behaves_like "a jekyll collection", "posts"

      it "matches the YYYY-MM-DD-title.md format for each post" do
        site.posts.each do |post|
          expect(post.path).to match(%r!_posts/\d{4}-\d{2}-\d{2}-.*.md$!)
        end
      end
    end

    context "with a custom collection" do
      let(:collections) { { "articles" => { "output" => true } } }
      let(:notion_config) do
        {
          "databases" => [{
            "id"         => "1ae33dd5f3314402948069517fa40ae2",
            "collection" => "articles",
          }],
        }
      end

      it_behaves_like "a jekyll collection", "articles"
    end
  end

  context "when filter is set" do
    let(:filter) { { :property => "blabla", :checkbox => { :equals => true } } }
    let(:notion_config) do
      {
        "databases" => [{
          "id"     => "1ae33dd5f3314402948069517fa40ae2",
          "filter" => filter,
        }],
      }
    end

    it do
      expect_any_instance_of(Notion::Client).to receive(:database_query)
        .with(hash_including(:filter => filter)).and_call_original

      VCR.use_cassette("notion_database") { site.process }
    end
  end

  context "when sort is set" do
    let(:sorts) { [{ :timestamp => "created_time", :direction => "ascending" }] }
    let(:notion_config) do
      {
        "databases" => [{
          "id"    => "1ae33dd5f3314402948069517fa40ae2",
          "sorts" => sorts,
        }],
      }
    end

    it do
      expect_any_instance_of(Notion::Client).to receive(:database_query)
        .with(hash_including(:sorts => sorts)).and_call_original

      VCR.use_cassette("notion_database") { site.process }
    end
  end

  context "when the site is rebuilt in watch mode" do
    let(:notion_config) do
      {
        "pages"     => [{
          "id" => "9dc17c9c-9d2e-469d-bbf0-f9648f3288d3",
        }],
        "databases" => [{
          "id" => "1ae33dd5f3314402948069517fa40ae2",
        }],
      }
    end

    before do
      allow(NotionToMd::Database).to receive(:call).and_return(instance_double(
                                                                 NotionToMd::Database, :pages => []
                                                               ))
      allow(NotionToMd::Page).to receive(:call).and_return(instance_double(NotionToMd::Page,
                                                                           :title => "title", :to_md => "content", :properties => {}))

      site.process
      site.process
    end

    it "queries notion database once" do
      expect(NotionToMd::Database).to have_received(:call).once
    end

    it "queries the notion page once" do
      expect(NotionToMd::Page).to have_received(:call).once
    end
  end

  context "when multiple databases" do
    let(:collections) { { "articles" => { "output" => true } } }
    let(:notion_config) do
      {
        "databases" => [{
          "id" => "1ae33dd5f3314402948069517fa40ae2",
        }, {
          "id"         => "1ae33dd5f3314402948069517fa40ae2",
          "collection" => "articles",
        },],
      }
    end

    before do
      VCR.use_cassette("notion_database") { site.process }
    end

    it_behaves_like "a jekyll collection", "posts"
    it_behaves_like "a jekyll collection", "articles"
  end

  context "when there is a post present in source dir" do
    let(:source_dir) { SOURCE_DIR_2 }
    let(:notion_config) do
      {
        "databases" => [{
          "id" => "1ae33dd5f3314402948069517fa40ae2",
        }],
      }
    end

    before do
      VCR.use_cassette("notion_database") { site.process }
    end

    it "adds the document to the posts collection" do
      expect(site.posts.size).to be == 8
    end

    it "keeps local posts" do
      # Files present in the source dir are added to the posts collection as Jekyll::Document instances
      post_1 = site.posts.find { |p| p.path.end_with?("2022-01-23-page-1.md") }
      post_2 = site.posts.find { |p| p.path.end_with?("2022-01-01-my-post.md") }
      expect(post_1).to be_an_instance_of(Jekyll::Document)
      expect(post_2).to be_an_instance_of(Jekyll::Document)
    end
  end

  context "when the date property is declared in a notion page" do
    # There's only one document in the database with the "Date" property set to "2021-12-30"
    #
    let(:date) { "2022-01-23" }
    let(:notion_config) do
      {
        "databases" => [{
          "id" => "1ae33dd5f3314402948069517fa40ae2",
        }],
      }
    end

    before do
      VCR.use_cassette("notion_database") { site.process }
    end

    it "sets the post date" do
      expect(site.posts.find { |p| p.data["date"] == Time.parse(date) }).not_to be_nil
    end

    it "sets the date in the filename" do
      expect(site.posts.find { |p| p.path.end_with?("#{date}-page-1.md") }).not_to be_nil
    end
  end

  context "when the date property is not declared in a notion page" do
    # There's only one document in the database with the "created_time" property set to "2022-09-17"
    #
    let(:created_time) { "2022-09-17" }
    let(:notion_config) do
      {
        "databases" => [{
          "id" => "1ae33dd5f3314402948069517fa40ae2",
        }],
      }
    end

    before do
      VCR.use_cassette("notion_database") { site.process }
    end

    it "sets the post from the created_time" do
      expect(site.posts.find { |p| p.data["date"] == Time.parse(created_time) }).not_to be_nil
    end

    it "sets the date from created_time in the filename" do
      expect(site.posts.find { |p| p.path.end_with?("#{created_time}-tables.md") }).not_to be_nil
    end
  end
end
