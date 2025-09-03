# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Setup: deprecated options" do
  subject(:build!) { site.process }

  let(:source_dir) { SOURCE_DIR }
  let(:dest_dir)   { DEST_TMP_DIR }
  let(:site)       { Jekyll::Site.new(config) }

  before do
    allow(Jekyll.logger).to receive(:warn)

    VCR.use_cassettes([
      { :name => "notion_page" },
      { :name => "notion_database" },
    ]) { build! }
  end

  context "with fetch_on_watch" do
    let(:config) do
      Jekyll.configuration(
        "source"      => source_dir,
        "destination" => dest_dir,
        "notion"      => {
          "fetch_on_watch" => false, # deprecated
          "databases"      => [{ "id" => "1ae33dd5f3314402948069517fa40ae2" }],
          "pages"          => [{ "id" => "9dc17c9c-9d2e-469d-bbf0-f9648f3288d3" }],
        }
      )
    end

    it "logs a warning message" do
      expect(Jekyll.logger).to have_received(:warn).with(
        a_string_matching(%r!Jekyll Notion:!i),
        a_string_matching(%r!fetch_on_watch!i)
      )
    end

    it_behaves_like "a page is rendered correctly", "Page 1"
    it_behaves_like "a collection is renderded correctly", "posts"
  end

  context "with database" do
    let(:config) do
      Jekyll.configuration(
        "source"      => source_dir,
        "destination" => dest_dir,
        "notion"      => {
          "database" => [{ "id" => "1ae33dd5f3314402948069517fa40ae2" }], # deprecated
          "pages"    => [{ "id" => "9dc17c9c-9d2e-469d-bbf0-f9648f3288d3" }],
        }
      )
    end

    it "logs a warning message" do
      expect(Jekyll.logger).to have_received(:warn).with(
        a_string_matching(%r!Jekyll Notion:!i),
        a_string_matching(%r!`database` key is deprecated!i)
      )
    end

    it_behaves_like "a page is rendered correctly", "Page 1"
    it_behaves_like "a collection is not renderded", "posts"
  end

  context "with page" do
    let(:config) do
      Jekyll.configuration(
        "source"      => source_dir,
        "destination" => dest_dir,
        "notion"      => {
          "databases" => [{ "id" => "1ae33dd5f3314402948069517fa40ae2" }],
          "page"      => { "id" => "9dc17c9c-9d2e-469d-bbf0-f9648f3288d3" }, # deprecated
        }
      )
    end

    it "logs a warning message" do
      expect(Jekyll.logger).to have_received(:warn).with(
        a_string_matching(%r!Jekyll Notion:!i),
        a_string_matching(%r!`page` key is deprecated!i)
      )
    end

    it_behaves_like "a page is not rendered", "Page 1"
    it_behaves_like "a collection is renderded correctly", "posts"
  end
end
