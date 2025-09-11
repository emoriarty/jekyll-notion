# frozen_string_literal: true

require "spec_helper"

RSpec.describe JekyllNotion::Cacheable do
  let(:cache_dir) { Dir.mktmpdir("cacheable-unit") }
  let(:test_class) do
    Class.new do
      prepend JekyllNotion::Cacheable

      attr_reader :id

      def initialize(id)
        @id = id
      end

      def call
        "original result"
      end
    end
  end
  let(:instance) { test_class.new("test-123") }

  before do
    JekyllNotion::Cacheable.configure(
      :cache_dir     => cache_dir,
      :cache_enabled => true
    )
  end

  after do
    FileUtils.rm_rf(cache_dir)
  end

  describe ".configure" do
    it "sets cache directory and enabled status" do
      # Use a valid temp directory instead of an invalid path
      temp_dir = Dir.mktmpdir("test-cache")

      JekyllNotion::Cacheable.configure(
        :cache_dir     => temp_dir,
        :cache_enabled => false
      )

      # cache_dir now returns VCR.configuration.cassette_library_dir for consistency
      expect(JekyllNotion::Cacheable.cache_dir).to eq(VCR.configuration.cassette_library_dir)
      expect(JekyllNotion::Cacheable.enabled?).to be false

      FileUtils.rm_rf(temp_dir)
    end
  end

  describe ".cache_dir" do
    it "always returns VCR configuration directory for consistency" do
      # cache_dir always returns VCR.configuration.cassette_library_dir
      # to ensure consistency between CassetteManager and VCR
      expect(JekyllNotion::Cacheable.cache_dir).to eq(VCR.configuration.cassette_library_dir)
    end

    it "maintains consistency when VCR configuration changes" do
      # Configure with a valid temp directory
      temp_dir = Dir.mktmpdir("consistency-test")

      JekyllNotion::Cacheable.configure(
        :cache_dir     => temp_dir,
        :cache_enabled => true
      )

      # Both should be the same after configuration
      expect(JekyllNotion::Cacheable.cache_dir).to eq(VCR.configuration.cassette_library_dir)
      expect(JekyllNotion::Cacheable.cache_dir).to eq(temp_dir)

      FileUtils.rm_rf(temp_dir)
    end
  end

  describe "#call" do
    context "when caching is disabled" do
      before do
        JekyllNotion::Cacheable.configure(
          :cache_dir     => cache_dir,
          :cache_enabled => false
        )
      end

      it "calls super without caching logic" do
        expect(VCR).not_to receive(:use_cassette)

        instance.call

        expect(instance.call).to eq("original result")
      end
    end

    context "when caching is enabled" do
      before do
        cassette_manager = instance_double(JekyllNotion::CassetteManager,
                                           :cassette_name_for => "cassette_name", :update_after_call => "")

        allow(JekyllNotion::CassetteManager).to receive(:new).and_return(cassette_manager)
        allow(VCR).to receive(:use_cassette).and_yield

        JekyllNotion::Cacheable.configure(
          :cache_dir     => cache_dir,
          :cache_enabled => true
        )
      end

      it "calls super uses with caching mechanism" do
        result = instance.call

        expect(VCR).to have_received(:use_cassette).with(
          "cassette_name"
        )
        expect(result).to eq("original result")
      end
    end
  end
end
