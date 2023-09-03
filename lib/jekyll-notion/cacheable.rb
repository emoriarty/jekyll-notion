# frozen_string_literal: true
#

module JekyllNotion
  module Cacheable
    def self.setup(cache_dir)
      # Using VCR to record and playback Notion API responses for caching
      VCR.configure do |config|
        config.cassette_library_dir = cache_path(cache_dir)
        config.hook_into :faraday # Faraday is used by notion-ruby-client gem
        config.filter_sensitive_data("<NOTION_TOKEN>") { ENV["NOTION_TOKEN"] }
        config.allow_http_connections_when_no_cassette = true
        config.default_cassette_options = {
          :allow_playback_repeats => true,
          :record => :new_episodes
        }
      end
    end

    def self.cache_path(path = nil)
      if path.nil?
        File.join(Dir.getwd, ".cache", "jekyll-notion", "vcr_cassettes")
      else
        File.join(Dir.getwd, path)
      end
    end

    def database_query(*args)
      VCR.use_cassette("#{args[0][:database_id]}") { super(*args) }
    end

    def block_children(*args)
      VCR.use_cassette("#{args[0][:block_id]}") { super(*args) }
    end

    def page(*args)
      VCR.use_cassette("#{args[0][:page_id]}") { super(*args) }
    end
  end
end
