# frozen_string_literal: true

require "spec_helper"
require "support/vcr_page"
require "support/vcr_data_page"
require "support/vcr_collection"

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

    let(:notion_config) do
      {
        "databases" => [{
          "id" => "1ae33dd5f3314402948069517fa40ae2",
        }],
      }
    end

    it_behaves_like "a jekyll collection", "posts"

    it "the posts collection is the same length" do
      puts site.collections["posts"].inspect
    end
  end
end
