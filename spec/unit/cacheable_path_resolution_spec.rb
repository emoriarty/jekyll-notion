# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Configuration: cache directory path handling" do
  describe "relative paths in config" do
    let(:relative_path) { "spec/fixtures/cache_test" }

    before do
      JekyllNotion::Cacheable.configure(:cache_dir => relative_path, :cache_enabled => true)
    end

    it "uses relative paths as provided in config" do
      expect(JekyllNotion::Cacheable.cache_dir).to eq(relative_path)
    end

    it "resolves relative paths correctly for file operations" do
      expected_path = File.join(Dir.pwd, relative_path)
      expect(File.expand_path(JekyllNotion::Cacheable.cache_dir)).to eq(expected_path)
    end
  end

  describe "absolute paths in config" do
    let(:absolute_path) { "/tmp/jekyll-notion-test-cache" }

    before do
      JekyllNotion::Cacheable.configure(:cache_dir => absolute_path, :cache_enabled => true)
    end

    it "handles absolute paths correctly" do
      expect(JekyllNotion::Cacheable.cache_dir).to eq(absolute_path)
    end

    it "preserves absolute paths without modification" do
      expect(File.expand_path(JekyllNotion::Cacheable.cache_dir)).to eq(absolute_path)
    end
  end

  describe "default cache directory" do
    before do
      JekyllNotion::Cacheable.configure(:cache_dir => nil, :cache_enabled => true)
      # Reset cached value to test fallback
      JekyllNotion::Cacheable.instance_variable_set(:@cache_dir, nil)
    end

    it "provides sensible default when no config specified" do
      expected_default = File.join(Dir.pwd, ".cache", "jekyll-notion", "vcr_cassettes")
      expect(JekyllNotion::Cacheable.cache_dir).to eq(expected_default)
    end
  end
end
