# frozen_string_literal: true

require "jekyll"
require 'yaml'
require File.expand_path("../lib/jekyll-notion", __dir__)

Jekyll.logger.log_level = :error

RSpec.configure do |config|
  config.run_all_when_everything_filtered = true
  config.filter_run :focus

  SOURCE_DIR = File.expand_path("fixtures/my_site", __dir__)
  DEST_DIR   = File.expand_path("dest", __dir__)
  NOTION_RESULTS = YAML.load_file(File.expand_path("fixtures/notion/results.yml", (__dir__)))

  def source_dir(*files)
    File.join(SOURCE_DIR, *files)
  end

  def dest_dir(*files)
    File.join(DEST_DIR, *files)
  end

  def get_notion_results
    NOTION_RESULTS
  end
end
