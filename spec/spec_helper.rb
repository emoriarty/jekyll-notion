# frozen_string_literal: true

require "jekyll"
require File.expand_path("../lib/jekyll-notion", __dir__)
require "simplecov"
require "webmock/rspec"
require "vcr"
require "tmpdir"
require "fileutils"

SimpleCov.start do
  enable_coverage :branch
end

ENV["JEKYLL_ENV"] = "test"
ENV["JEKYLL_NOTION_CACHE"] = "false"

Jekyll.logger.log_level = :error

VCR.configure do |config|
  config.cassette_library_dir = "spec/fixtures/spec_cache"
  config.hook_into :webmock

  # Redact the Notion token from the VCR cassettes
  config.before_record do |interaction|
    to_be_redacted = interaction.request.headers["Authorization"]

    to_be_redacted.each do |redacted_text|
      interaction.filter!(redacted_text, "[REDACTED]")
    end
  end

  config.default_cassette_options = {
    :record                 => :new_episodes,
    :allow_playback_repeats => true,
    :match_requests_on      => [:method, :uri, :body],
  }
end

RSpec.configure do |config|
  # Load support files
  Dir[
    File.join(__dir__, "support/**/*.rb"),
    File.join(__dir__, "integration/**/support/**/*.rb")
  ].sort.each { |f| require f }

  config.include GoldenHelper
  config.run_all_when_everything_filtered = true
  config.filter_run :focus

  SOURCE_DIR = File.expand_path("fixtures/my_site", __dir__)
  SOURCE_DIR_2 = File.expand_path("fixtures/my_site_2", __dir__)
  DEST_DIR = File.expand_path("dest", __dir__)
  DEST_TMP_DIR = Dir.mktmpdir("jekyll-dest-")
  ENV_REL_CACHE_DIR = File.join("spec", "fixtures", "env_cache")
  ENV_ABS_CACHE_DIR = File.expand_path(ENV_REL_CACHE_DIR, Dir.getwd)

  def dest_dir(*files)
    File.join(DEST_DIR, *files)
  end
end
