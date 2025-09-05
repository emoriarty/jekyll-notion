# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Caching: JEKYLL_NOTION_CACHE" do
  let(:cache_dir) { Dir.mktmpdir("jekyll-cache-") }
  let(:site) { Jekyll::Site.new(config) }
  let(:config) do
    Jekyll.configuration(
      "source"      => SOURCE_DIR,
      "destination" => DEST_TMP_DIR,
      "notion"      => {
        "cache_dir" => cache_dir,
        "pages"     => [{ "id" => "9dc17c9c-9d2e-469d-bbf0-f9648f3288d3" }],
      }
    )
  end

  original_value = nil

  before do
    original_value = ENV["JEKYLL_NOTION_CACHE"]
    ENV["JEKYLL_NOTION_CACHE"] = falsy_value

    allow(NotionToMd::Page).to receive(:call).and_return(
      instance_double("NotionToMd::Page", :title => "blabla", :to_md => "body", :properties => {})
    )
    site.process
  end

  after do
    ENV["JEKYLL_NOTION_CACHE"] = original_value
  end

  %w(0 false FALSE no NO False).each do |current_value|
    context "with #{current_value}" do
      let(:falsy_value) { current_value }

      it "disables caching" do
        expect(JekyllNotion::Cacheable.enabled?).to be(false)
      end
    end
  end

  %w(1 true TRUE yes YES True).each do |current_value|
    context "with #{current_value}" do
      let(:falsy_value) { current_value }

      it "enables caching" do
        expect(JekyllNotion::Cacheable.enabled?).to be(true)
      end
    end
  end

  context "with empty string" do
    let(:falsy_value) { "" }

    it "disables caching" do
      expect(JekyllNotion::Cacheable.enabled?).to be(true)
    end
  end

  context "with nil (unset)" do
    let(:falsy_value) { nil }

    before do
      ENV.delete("JEKYLL_NOTION_CACHE")
      site.process
    end

    it "enables caching by default" do
      expect(JekyllNotion::Cacheable.enabled?).to be(true)
    end
  end
end
