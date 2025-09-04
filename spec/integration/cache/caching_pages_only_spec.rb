# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Caching: pages only" do
  let(:app_cache_dir) { File.expand_path("spec/fixtures/app_cache", Dir.getwd) }
  let(:site) { Jekyll::Site.new(config) }
  let(:config) do
    Jekyll.configuration(
      "source"      => SOURCE_DIR,
      "destination" => DEST_TMP_DIR,
      "notion"      => {
        "cache"     => "true",
        "cache_dir" => app_cache_dir,
        "pages"     => [
          { "id" => "9dc17c9c-9d2e-469d-bbf0-f9648f3288d3" }, # Notion "Page 1"
          { "id" => "0b8c4501209246c1b800529623746afc" }, # Notion "Page 2"
        ],
        "databases" => [{ "id" => "1ae33dd5f3314402948069517fa40ae2" }],
      }
    )
  end

  def compose_filepath(title, page_id)
    File.join(app_cache_dir, "pages",
              "#{Jekyll::Utils.slugify(title)}-#{page_id.delete("-")}.yml")
  end

  before do
    VCR.use_cassette("caching_pages_only") { site.process }
  end

  it "page is imported" do
    expect(site.posts).not_to be_empty
  end

  it "posts are imported" do
    expect(site.posts).not_to be_empty
  end

  it "only pages are cached" do
    files = Dir[File.join(app_cache_dir, "**", "*.yml")]

    site.pages.each do |page|
      filepath = compose_filepath(page.data["title"], page.data["id"])

      expect(File.exist?(filepath)).to be true
    end

    site.posts.each do |post|
      filepath = compose_filepath(post.data["title"], post.data["id"])

      expect(File.exist?(filepath)).to be true
    end
  end
end
