# frozen_string_literal: true

require "spec_helper"
require "support/vcr_page"
require "support/vcr_data_page"
require "support/vcr_collection"
require "support/notion_token"

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
      it "logs a warning" do
        VCR.use_cassette("notion_page") { site.process }

        expect(Jekyll.logger).to have_received(:warn).with("Jekyll Notion:",
                                                           "No configuration provided")
      end

      it "does not create an instance of Notion::Client" do
        expect(Notion::Client).not_to have_received(:new)
      end
    end

    context "when NOTION_TOKEN is not present" do
      it_behaves_like "NOTION_TOKEN is not provided", nil
    end

    context "when NOTION_TOKEN is empty" do
      it_behaves_like "NOTION_TOKEN is not provided", ""
    end

    context "when the databases property is nil" do
      before do
        VCR.use_cassette("notion_database_empty") { site.process }
      end

      let(:notion_config) { { "databases" => nil } }

      it "does not create a collection" do
        expect_any_instance_of(Notion::Client).not_to receive(:database_query).and_call_original
      end
    end

    context "when the databases property id is nil" do
      before do
        VCR.use_cassette("notion_database_empty") { site.process }
      end

      let(:notion_config) { { "databases" => [{ id => nil }] } }

      it "does not create a collection" do
        expect_any_instance_of(Notion::Client).not_to receive(:database_query).and_call_original
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
end
