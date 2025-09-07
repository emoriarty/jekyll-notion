# frozen_string_literal: true

require "spec_helper"
require "ostruct"

RSpec.describe JekyllNotion::Cacheable do
  let(:cache_dir) { Dir.mktmpdir("cacheable-unit-") }
  let(:test_class) do
    Class.new do
      prepend JekyllNotion::Cacheable

      def call(**kwargs)
        # Simulate API call behavior - this is what super calls
        OpenStruct.new(:title => "Test Page #{kwargs[:id]}", :content => "Test content")
      end

      def extract_title(result)
        result.title
      end
    end
  end
  let(:instance) { test_class.new }

  before do
    JekyllNotion::Cacheable.configure(:cache_dir => cache_dir, :cache_enabled => true)
  end

  after do
    FileUtils.rm_rf(cache_dir)
  end

  describe "#call" do
    context "when caching is disabled" do
      before do
        JekyllNotion::Cacheable.configure(:cache_dir => cache_dir, :cache_enabled => false)
      end

      it "calls super without caching logic" do
        expect(instance).to receive(:call).and_call_original
        allow(VCR).to receive(:use_cassette)

        result = instance.call(:id => "test-123")

        expect(VCR).not_to have_received(:use_cassette)
        expect(result.title).to eq("Test Page test-123")
      end
    end

    context "when caching is enabled" do
      it "uses VCR cassette for caching" do
        expect(VCR).to receive(:use_cassette).with(
          "pages/test123",
          :record                 => :new_episodes,
          :allow_playback_repeats => true
        ).and_yield

        result = instance.call(:id => "test-123")
        expect(result.title).to eq("Test Page test-123")
      end

      it "updates index and renames cassette when title is available" do
        allow(VCR).to receive(:use_cassette).and_yield
        allow(instance).to receive(:rename_cassette_if_needed)
        allow(instance).to receive(:update_index_yaml)

        result = instance.call(:id => "test-123")

        expect(instance).to have_received(:rename_cassette_if_needed).with(
          cache_dir,
          :from => "pages/test123",
          :to   => "pages/test-page-test-123-test123"
        )
        expect(instance).to have_received(:update_index_yaml).with(
          :id     => "test123",
          :pretty => "pages/test-page-test-123-test123"
        )
      end

      it "sanitizes IDs by removing dashes" do
        expect(VCR).to receive(:use_cassette).with(
          "pages/test123456",
          anything
        ).and_yield

        instance.call(:id => "test-123-456")
      end
    end
  end

  describe "#preferred_cassette_name" do
    let(:page_id) { "test123" }

    context "when index mapping exists and file exists" do
      before do
        allow(instance).to receive(:load_index_yaml).and_return({ page_id => "pages/pretty-name" })
        allow(File).to receive(:exist?).with(File.join(cache_dir,
                                                       "pages/pretty-name.yml")).and_return(true)
      end

      it "returns the pretty name from index" do
        result = instance.preferred_cassette_name(cache_dir, page_id)
        expect(result).to eq("pages/pretty-name")
      end
    end

    context "when existing file matches ID pattern" do
      before do
        allow(instance).to receive(:load_index_yaml).and_return({})
        allow(instance).to receive(:find_existing_by_id).with(cache_dir,
                                                              page_id).and_return("pages/old-title-test123")
      end

      it "returns the existing filename" do
        result = instance.preferred_cassette_name(cache_dir, page_id)
        expect(result).to eq("pages/old-title-test123")
      end
    end

    context "when no existing files found" do
      before do
        allow(instance).to receive(:load_index_yaml).and_return({})
        allow(instance).to receive(:find_existing_by_id).with(cache_dir, page_id).and_return(nil)
      end

      it "returns plain ID fallback" do
        result = instance.preferred_cassette_name(cache_dir, page_id)
        expect(result).to eq("pages/test123")
      end
    end
  end

  describe "#find_existing_by_id" do
    let(:page_id) { "test123" }

    context "when matching files exist" do
      before do
        FileUtils.mkdir_p(File.join(cache_dir, "pages"))
        File.write(File.join(cache_dir, "pages", "some-title-test123.yml"), "cached data")
      end

      it "returns the basename without extension" do
        result = instance.find_existing_by_id(cache_dir, page_id)
        expect(result).to eq("pages/some-title-test123")
      end
    end

    context "when no matching files exist" do
      it "returns nil" do
        result = instance.find_existing_by_id(cache_dir, page_id)
        expect(result).to be_nil
      end
    end
  end

  describe "#rename_cassette_if_needed" do
    let(:src_file) { File.join(cache_dir, "pages/old-name.yml") }
    let(:dst_file) { File.join(cache_dir, "pages/new-name.yml") }

    before do
      FileUtils.mkdir_p(File.join(cache_dir, "pages"))
    end

    context "when source and destination are the same" do
      it "does nothing" do
        expect(FileUtils).not_to receive(:mv)
        instance.rename_cassette_if_needed(cache_dir, :from => "pages/same", :to => "pages/same")
      end
    end

    context "when source file exists and destination doesn't" do
      before do
        File.write(src_file, "cache content")
      end

      it "renames the file" do
        instance.rename_cassette_if_needed(cache_dir, :from => "pages/old-name",
                                                      :to   => "pages/new-name")

        expect(File.exist?(src_file)).to be false
        expect(File.exist?(dst_file)).to be true
        expect(File.read(dst_file)).to eq("cache content")
      end
    end

    context "when source doesn't exist" do
      it "does nothing" do
        expect(FileUtils).not_to receive(:mv)
        instance.rename_cassette_if_needed(cache_dir, :from => "pages/nonexistent",
                                                      :to   => "pages/new-name")
      end
    end

    context "when destination already exists" do
      before do
        File.write(src_file, "old content")
        File.write(dst_file, "new content")
      end

      it "does nothing to avoid overwriting" do
        instance.rename_cassette_if_needed(cache_dir, :from => "pages/old-name",
                                                      :to   => "pages/new-name")

        expect(File.read(dst_file)).to eq("new content")
        expect(File.exist?(src_file)).to be true
      end
    end
  end

  describe "#load_index_yaml" do
    let(:index_file) { File.join(cache_dir, ".pages_index.yml") }

    context "when index file exists and is valid" do
      before do
        FileUtils.mkdir_p(cache_dir)
        File.write(index_file, { "page1" => "pages/title1", "page2" => "pages/title2" }.to_yaml)
      end

      it "returns the parsed YAML content" do
        result = instance.send(:load_index_yaml)
        expect(result).to eq({ "page1" => "pages/title1", "page2" => "pages/title2" })
      end
    end

    context "when index file doesn't exist" do
      it "returns empty hash" do
        result = instance.send(:load_index_yaml)
        expect(result).to eq({})
      end
    end

    context "when index file has invalid YAML" do
      before do
        FileUtils.mkdir_p(cache_dir)
        File.write(index_file, "invalid: yaml: content: [")
      end

      it "returns empty hash on syntax error" do
        result = instance.send(:load_index_yaml)
        expect(result).to eq({})
      end
    end
  end

  describe "#update_index_yaml" do
    let(:index_file) { File.join(cache_dir, ".pages_index.yml") }

    it "creates new index file with mapping" do
      instance.send(:update_index_yaml, :id => "page123", :pretty => "pages/nice-title")

      expect(File.exist?(index_file)).to be true
      content = YAML.safe_load(File.read(index_file))
      expect(content).to eq({ "page123" => "pages/nice-title" })
    end

    it "updates existing index file" do
      FileUtils.mkdir_p(cache_dir)
      File.write(index_file, { "existing" => "pages/existing" }.to_yaml)

      instance.send(:update_index_yaml, :id => "new", :pretty => "pages/new-title")

      content = YAML.safe_load(File.read(index_file))
      expect(content).to eq({ "existing" => "pages/existing", "new" => "pages/new-title" })
    end

    it "doesn't update if mapping is unchanged" do
      FileUtils.mkdir_p(cache_dir)
      File.write(index_file, { "page1" => "pages/same" }.to_yaml)

      original_mtime = File.mtime(index_file)
      sleep 0.01 # Ensure time difference would be detectable

      instance.send(:update_index_yaml, :id => "page1", :pretty => "pages/same")

      expect(File.mtime(index_file)).to eq(original_mtime)
    end
  end

  describe "utility methods" do
    describe "#sanitize_title" do
      it "uses Jekyll's slugify for title sanitization" do
        expect(Jekyll::Utils).to receive(:slugify).with("My Title!").and_return("my-title")
        result = instance.send(:sanitize_title, "My Title!")
        expect(result).to eq("my-title")
      end
    end

    describe "#sanitize_id" do
      it "removes dashes from IDs" do
        result = instance.send(:sanitize_id, "abc-123-def")
        expect(result).to eq("abc123def")
      end
    end
  end
end

RSpec.describe "JekyllNotion::Cacheable.cache_dir" do
  context "when environment variable is set" do
    around do |example|
      test_cache_dir = "/tmp/jekyll-notion-env-test"
      original_env = ENV["JEKYLL_NOTION_CACHE_DIR"]
      original_cache_dir = JekyllNotion::Cacheable.instance_variable_get(:@cache_dir)
      original_cache_enabled = JekyllNotion::Cacheable.instance_variable_get(:@cache_enabled)

      # Clear any previous configuration
      JekyllNotion::Cacheable.instance_variable_set(:@cache_dir, nil)
      JekyllNotion::Cacheable.instance_variable_set(:@cache_enabled, nil)
      ENV["JEKYLL_NOTION_CACHE_DIR"] = test_cache_dir

      begin
        example.run
      ensure
        ENV["JEKYLL_NOTION_CACHE_DIR"] = original_env
        JekyllNotion::Cacheable.instance_variable_set(:@cache_dir, original_cache_dir)
        JekyllNotion::Cacheable.instance_variable_set(:@cache_enabled, original_cache_enabled)
      end
    end

    it "uses environment variable for cache directory" do
      expect(JekyllNotion::Cacheable.cache_dir).to eq("/tmp/jekyll-notion-env-test")
    end
  end

end
