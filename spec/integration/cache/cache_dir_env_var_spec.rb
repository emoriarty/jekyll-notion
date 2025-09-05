# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Caching: JEKYLL_NOTION_CACHE_DIR" do
  let(:site) { Jekyll::Site.new(config) }
  let(:config) do
    Jekyll.configuration(
      "source"      => SOURCE_DIR,
      "destination" => DEST_TMP_DIR,
      "notion"      => {
        "cache" => "true",
        "pages" => [
          { "id" => "9dc17c9c-9d2e-469d-bbf0-f9648f3288d3" }, # Notion "Page 1"
          { "id" => "0b8c4501209246c1b800529623746afc" }, # Notion "Page 2"
        ],
      }
    )
  end

  around do |example|
    original_env = ENV["JEKYLL_NOTION_CACHE_DIR"]
    ENV["JEKYLL_NOTION_CACHE_DIR"] = ENV_ABS_CACHE_DIR

    begin
      example.run
    ensure
      ENV["JEKYLL_NOTION_CACHE_DIR"] = original_env
    end
  end

  before do
    VCR.use_cassette("cache_dir_env_var") { site.process }
  end

  it_behaves_like "pages are cached in the specified folder", ENV_ABS_CACHE_DIR

  it "uses environment variable for cache directory" do
    expect(JekyllNotion::Cacheable.cache_dir).to eq(ENV_ABS_CACHE_DIR)
  end
end
