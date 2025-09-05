# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Caching: pages only" do
  let(:site) { Jekyll::Site.new(config) }
  let(:config) do
    Jekyll.configuration(
      "source"      => SOURCE_DIR,
      "destination" => DEST_TMP_DIR,
      "notion"      => {
        "cache"     => "true",
        "cache_dir" => ENV_ABS_CACHE_DIR,
        "pages"     => [
          { "id" => "9dc17c9c-9d2e-469d-bbf0-f9648f3288d3" }, # Notion "Page 1"
          { "id" => "0b8c4501209246c1b800529623746afc" }, # Notion "Page 2"
        ],
        "databases" => [{ "id" => "1ae33dd5f3314402948069517fa40ae2" }],
      }
    )
  end

  before do
    VCR.use_cassette("caching_pages_only") { site.process }
  end

  it_behaves_like "pages are cached in the specified folder", ENV_ABS_CACHE_DIR

  it "page is imported" do
    expect(site.posts).not_to be_empty
  end

  it "posts are imported" do
    expect(site.posts).not_to be_empty
  end
end
