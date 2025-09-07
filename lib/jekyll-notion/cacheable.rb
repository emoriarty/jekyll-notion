# frozen_string_literal: true

require "yaml"
require "fileutils"

module JekyllNotion
  module Cacheable
    INDEX_BASENAME = ".pages_index.yml" # hidden YAML registry in cache dir
    PAGES_DIR = "pages"

    class << self
      def configure(cache_dir:, cache_enabled:)
        @cache_dir = cache_dir
        @cache_enabled = cache_enabled

        VCR.configure do |config|
          config.cassette_library_dir = self.cache_dir
          config.hook_into :faraday # Faraday is used by notion-ruby-client gem
          config.filter_sensitive_data("<REDACTED>") { ENV.fetch("NOTION_TOKEN", nil) }
          config.allow_http_connections_when_no_cassette = true
          config.default_cassette_options = {
            :allow_playback_repeats => true,
            :record                 => :new_episodes,
          }
        end
      end

      def cache_dir
        @cache_dir || ENV["JEKYLL_NOTION_CACHE_DIR"] || File.join(Dir.pwd, ".cache",
                                                                  "jekyll-notion", "vcr_cassettes")
      end

      def enabled?
        @cache_enabled
      end
    end

    def call(**kwargs)
      return super unless JekyllNotion::Cacheable.enabled?

      id = sanitize_id(kwargs[:id])
      dir = JekyllNotion::Cacheable.cache_dir
      cassette_name = preferred_cassette_name(dir, id)
      result = nil

      with_cassette_dir(dir) do
        VCR.use_cassette(
          cassette_name, # e.g., "pages/my_title-<id>" or "pages/<id>"
          :record                 => :new_episodes,
          :allow_playback_repeats => true
        ) do
          result = super(**kwargs)
        end
      end

      if (title = extract_title(result)).to_s != ""
        pretty = "#{PAGES_DIR}/#{sanitize_title(title)}-#{id}"
        rename_cassette_if_needed(dir, :from => cassette_name, :to => pretty)
        update_index_yaml(:id => id, :pretty => pretty)
      end

      result
    end

    def with_cassette_dir(path)
      old_dir = VCR.configuration.cassette_library_dir
      VCR.configuration.cassette_library_dir = path
      yield
    ensure
      VCR.configuration.cassette_library_dir = old_dir
    end

    def preferred_cassette_name(dir, id)
      # a) index mapping wins
      if (pretty = load_index_yaml[id]) && File.exist?(File.join(dir, "#{pretty}.yml"))
        return pretty
      end
      # b) any existing "*-id.yml" (handles prior runs / title changes)
      if (found = find_existing_by_id(dir, id))
        return found
      end

      # c) fallback to plain id (first run)
      "#{PAGES_DIR}/#{id}"
    end

    def find_existing_by_id(dir, id)
      matches = Dir[File.join(dir, "pages", "*-#{id}.yml")]
      return nil if matches.empty?

      File.join(PAGES_DIR, File.basename(matches.first, ".yml"))
    end

    def rename_cassette_if_needed(dir, from:, to:)
      return if from == to

      src = File.join(dir, "#{from}.yml")
      dst = File.join(dir, "#{to}.yml")
      return unless File.exist?(src) # nothing to rename
      return if File.exist?(dst)     # someone already wrote it (another thread/process)

      FileUtils.mkdir_p(File.dirname(dst))
      FileUtils.mv(src, dst)
    rescue SystemCallError
      # Best-effort: if a race occurs, ignore—next run will pick up the pretty file.
      nil
    end

    private

    def index_path
      File.join(JekyllNotion::Cacheable.cache_dir, INDEX_BASENAME)
    end

    def load_index_yaml
      return {} unless File.exist?(index_path)

      YAML.safe_load(File.read(index_path), :permitted_classes => [], :aliases => false) || {}
    rescue Psych::SyntaxError
      {}
    end

    def update_index_yaml(id:, pretty:)
      idx = load_index_yaml
      return if idx[id] == pretty

      FileUtils.mkdir_p(File.dirname(index_path))
      tmp = "#{index_path}.tmp"
      idx[id] = pretty
      File.write(tmp, idx.to_yaml)
      FileUtils.mv(tmp, index_path)
    end

    def sanitize_title(str)
      Jekyll::Utils.slugify(str)
    end

    def sanitize_id(id)
      id.delete("-")
    end

    def extract_title(metadata)
      metadata.title
    end
  end
end
