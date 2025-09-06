# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Databases: filtered and sorted import" do
  context "with filter configuration" do
    let(:filter) { { "property" => "Select", "select" => { "equals" => "select1" } } }
    let(:config) do
      Jekyll.configuration(
        "source"      => SOURCE_DIR,
        "destination" => DEST_DIR,
        "notion"      => {
          "databases" => [{
            "id"     => "1ae33dd5f3314402948069517fa40ae2",
            "filter" => filter,
          }],
        }
      )
    end

    let(:site) { Jekyll::Site.new(config) }

    it_behaves_like "passes filter to notion client"
    it_behaves_like "filters posts correctly", 2

    context "when processing site" do
      before do
        VCR.use_cassette("notion_database") { site.process }
      end

      it_behaves_like "a collection is renderded correctly", "posts"
      it_behaves_like "a jekyll collection", "posts"
    end
  end

  context "with sort configuration" do
    let(:sorts) { [{ "timestamp" => "created_time", "direction" => "ascending" }] }
    let(:config) do
      Jekyll.configuration(
        "source"      => SOURCE_DIR,
        "destination" => DEST_DIR,
        "notion"      => {
          "databases" => [{
            "id"    => "1ae33dd5f3314402948069517fa40ae2",
            "sorts" => sorts,
          }],
        }
      )
    end

    let(:site) { Jekyll::Site.new(config) }

    it_behaves_like "passes sorts to notion client"
    it_behaves_like "sorts posts by created_time ascending"

    context "with descending sort" do
      let(:sorts) { [{ "timestamp" => "created_time", "direction" => "descending" }] }

      it_behaves_like "sorts posts by created_time descending"
    end

    context "when processing site" do
      before do
        VCR.use_cassette("notion_database") { site.process }
      end

      it_behaves_like "a collection is renderded correctly", "posts"
      it_behaves_like "a jekyll collection", "posts"
    end
  end

  context "with both filter and sort configuration" do
    let(:filter) { { "property" => "Select", "select" => { "equals" => "select1" } } }
    let(:sorts) { [{ "timestamp" => "created_time", "direction" => "descending" }] }
    let(:config) do
      Jekyll.configuration(
        "source"      => SOURCE_DIR,
        "destination" => DEST_DIR,
        "notion"      => {
          "databases" => [{
            "id"     => "1ae33dd5f3314402948069517fa40ae2",
            "filter" => filter,
            "sorts"  => sorts,
          }],
        }
      )
    end

    let(:site) { Jekyll::Site.new(config) }

    it_behaves_like "passes filter and sorts to notion client"
    it_behaves_like "filters posts correctly", 2
    it_behaves_like "sorts posts by created_time descending"

    context "when processing site" do
      before do
        VCR.use_cassette("notion_database") { site.process }
      end

      it_behaves_like "a collection is renderded correctly", "posts"
      it_behaves_like "a jekyll collection", "posts"
    end
  end
end
