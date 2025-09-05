# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Caching: cache directory path handling" do
  let(:site) { Jekyll::Site.new(config) }

  describe "relative paths in config" do
    let(:relative_path) { ENV_REL_CACHE_DIR }
    let(:config) do
      Jekyll.configuration(
        "source"      => SOURCE_DIR,
        "destination" => DEST_TMP_DIR,
        "notion"      => {
          "cache"     => "true",
          "cache_dir" => relative_path,
          "pages"     => [{ "id" => "9dc17c9c-9d2e-469d-bbf0-f9648f3288d3" }],
        }
      )
    end

    before do
      VCR.use_cassette("cache_dir_paths_relative") { site.process }
    end

    it "uses relative paths as provided in config" do
      expect(JekyllNotion::Cacheable.cache_dir).to eq(relative_path)

      # Check if files are actually created in the expected location
      expected_path = File.join(Dir.pwd, relative_path)
      cache_files = Dir[File.join(expected_path, "**", "*.yml")]
      expect(cache_files).not_to be_empty
    end
  end

  describe "absolute paths in config" do
    let(:absolute_path) { ENV_ABS_CACHE_DIR }
    let(:config) do
      Jekyll.configuration(
        "source"      => SOURCE_DIR,
        "destination" => DEST_TMP_DIR,
        "notion"      => {
          "cache"     => "true",
          "cache_dir" => absolute_path,
          "pages"     => [{ "id" => "9dc17c9c-9d2e-469d-bbf0-f9648f3288d3" }],
        }
      )
    end

    before do
      VCR.use_cassette("cache_dir_paths_absolute") { site.process }
    end

    it "handles absolute paths correctly" do
      expect(JekyllNotion::Cacheable.cache_dir).to eq(absolute_path)

      # Check if files are actually created in the expected location
      cache_files = Dir[File.join(absolute_path, "**", "*.yml")]
      expect(cache_files).not_to be_empty
    end
  end
end
