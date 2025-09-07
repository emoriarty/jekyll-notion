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
  add_filter "spec/"
end

ENV["JEKYLL_ENV"] = "test"

Jekyll.logger.log_level = :error

# Set VCR configuration override for tests
JekyllNotion::Cacheable.vcr_config = lambda do |config|
  # Override cache directory for tests (ignore production cache_dir)
  config.cassette_library_dir = "spec/fixtures/spec_cache"

  # Use webmock instead of faraday for tests
  config.hook_into :webmock

  # Preserve test-specific filtering for authorization headers
  config.filter_sensitive_data("[REDACTED]") do |interaction|
    interaction.request.headers["Authorization"]&.first
  end

  # Preserve test-specific cookie filtering
  config.before_record do |interaction|
    if interaction.response.headers["Set-Cookie"]
      interaction.response.headers["Set-Cookie"].map! { |_cookie| "[REDACTED]" }
    end
  end

  # Override default cassette options for tests
  config.default_cassette_options = {
    :record                 => :new_episodes,
    :allow_playback_repeats => true,
    :match_requests_on      => [:method, :uri, :body],
  }
end

# The VCR configuration is now handled by the lambda above
# This avoids the conflict between test and production VCR settings

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
  DEST_DIR = Dir.mktmpdir("jekyll-site")
end
