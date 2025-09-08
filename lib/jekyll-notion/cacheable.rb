# frozen_string_literal: true

require_relative "cassette_manager"

module JekyllNotion
  module Cacheable

    class << self
      def configure(cache_dir:, cache_enabled:)
        @cache_dir = cache_dir
        @cache_enabled = cache_enabled

        configure_vcr
      end

      def cache_dir
        # Always return VCR's configured directory to ensure consistency
        # between CassetteManager operations and VCR cassette storage
        VCR.configuration.cassette_library_dir
      end

      def enabled?
        @cache_enabled
      end

      private

      def configure_vcr
        # Determine the directory to use based on configuration and environment
        target_dir = @cache_dir || ENV["JEKYLL_NOTION_CACHE_DIR"] || File.join(Dir.pwd, ".cache", "jekyll-notion", "vcr_cassettes")

        VCR.configure do |config|
          config.cassette_library_dir = target_dir
          config.hook_into :faraday # Faraday is used by notion-ruby-client gem
          config.filter_sensitive_data("<REDACTED>") { ENV.fetch("NOTION_TOKEN", nil) }
          config.allow_http_connections_when_no_cassette = true
          config.default_cassette_options = {
            :allow_playback_repeats => true,
            :record                 => :new_episodes,
          }
        end
      end
    end

    def call
      return super unless JekyllNotion::Cacheable.enabled?

      cassette_manager = CassetteManager.new(JekyllNotion::Cacheable.cache_dir)
      cassette_name = cassette_manager.cassette_name_for(self.id)
      result = nil

      VCR.use_cassette(
        cassette_name,
        :record                 => :new_episodes,
        :allow_playback_repeats => true
      ) do
        result = super
      end

      cassette_manager.update_after_call(self.id, result)
      result
    end


  end
end
