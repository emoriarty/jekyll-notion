# frozen_string_literal: true

require "yaml"
require "fileutils"

module JekyllNotion
  class CassetteManager
    INDEX_BASENAME = ".pages_index.yml"
    PAGES_DIR = "pages"

    def initialize(cache_dir)
      @cache_dir = cache_dir
    end

    def cassette_name_for(id)
      sanitized_id = sanitize_id(id)
      
      # a) index mapping wins
      if (pretty = load_index_yaml[sanitized_id]) && File.exist?(cassette_path(pretty))
        return pretty
      end
      
      # b) any existing "*-id.yml" (handles prior runs / title changes)
      if (found = find_existing_by_id(sanitized_id))
        return found
      end

      # c) fallback to plain id (first run)
      "#{PAGES_DIR}/#{sanitized_id}"
    end

    def update_after_call(id, result)
      return unless (title = extract_title(result)).to_s != ""

      sanitized_id = sanitize_id(id)
      current_cassette = cassette_name_for(sanitized_id)
      pretty_name = "#{PAGES_DIR}/#{sanitize_title(title)}-#{sanitized_id}"

      rename_cassette_if_needed(from: current_cassette, to: pretty_name)
      update_index_yaml(id: sanitized_id, pretty: pretty_name)
    end

    private

    attr_reader :cache_dir

    def cassette_path(name)
      File.join(cache_dir, "#{name}.yml")
    end

    def find_existing_by_id(id)
      matches = Dir[File.join(cache_dir, "pages", "*-#{id}.yml")]
      return nil if matches.empty?

      File.join(PAGES_DIR, File.basename(matches.first, ".yml"))
    end

    def rename_cassette_if_needed(from:, to:)
      return if from == to

      src = cassette_path(from)
      dst = cassette_path(to)
      return unless File.exist?(src)
      return if File.exist?(dst)

      FileUtils.mkdir_p(File.dirname(dst))
      FileUtils.mv(src, dst)
    rescue SystemCallError
      nil
    end

    def index_path
      File.join(cache_dir, INDEX_BASENAME)
    end

    def load_index_yaml
      return {} unless File.exist?(index_path)

      YAML.safe_load(File.read(index_path), permitted_classes: [], aliases: false) || {}
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