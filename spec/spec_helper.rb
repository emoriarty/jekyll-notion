# frozen_string_literal: true

require "jekyll"
require "yaml"
require File.expand_path("../lib/jekyll-notion", __dir__)

Jekyll.logger.log_level = :error

RSpec.configure do |config|
  config.run_all_when_everything_filtered = true
  config.filter_run :focus

  SOURCE_DIR = File.expand_path("fixtures/my_site", __dir__)
  SOURCE_DIR_2 = File.expand_path("fixtures/my_site_2", __dir__)
  DEST_DIR = File.expand_path("dest", __dir__)
  NOTION_RESULTS = YAML.load_file(File.expand_path("fixtures/notion/results.yml", __dir__))
  NOTION_RESULTS_2 = YAML.load_file(File.expand_path("fixtures/notion/results_2.yml", __dir__))
  NOTION_RESULTS_3 = YAML.load_file(File.expand_path("fixtures/notion/results_3.yml", __dir__))
  MD_FILES = Dir[File.expand_path("fixtures/md_files/*.md",
                                  __dir__)].each_with_object({}) do |file, memo|
    value = File.read(file)
    key = File.basename(file, ".md")
    memo[key] = value
  end

  def dest_dir(*files)
    File.join(DEST_DIR, *files)
  end

  def md_files
    MD_FILES
  end
end
