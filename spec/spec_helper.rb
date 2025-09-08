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

RSpec.configure do |config|
  # Load support files
  Dir[
    File.join(__dir__, "support/**/*.rb"),
  ].sort.each { |f| require f }

  config.include GoldenHelper
  config.run_all_when_everything_filtered = true
  config.filter_run :focus

  SOURCE_DIR = File.expand_path("fixtures/my_site", __dir__)
  SOURCE_DIR_2 = File.expand_path("fixtures/my_site_2", __dir__)
  DEST_DIR = Dir.mktmpdir("jekyll-site")
end

# VCR configuration override with conditional logic
# This prepend module adds environment-aware VCR configuration
JekyllNotion::Cacheable.singleton_class.prepend(Module.new do
  def configure_vcr
    # Detect if we're in an integration test context by checking file path
    integration_test = if defined?(RSpec) && RSpec.current_example
                         file_path = RSpec.current_example.example_group.metadata[:file_path]
                         file_path&.include?("spec/integration/")
                       else
                         false
                       end

    if integration_test
      # Integration test VCR configuration
      target_dir = "spec/fixtures/spec_cache"

      VCR.configure do |config|
        config.cassette_library_dir = target_dir
        config.hook_into :webmock

        # Redact the Notion token from the VCR cassettes
        config.filter_sensitive_data("[AUTH_REDACTED]") do |interaction|
          interaction.request.headers["Authorization"]&.first
        end

        # Redact cookies from the VCR cassettes
        config.before_record do |interaction|
          if interaction.response.headers["Set-Cookie"]
            interaction.response.headers["Set-Cookie"].map! { |_cookie| "[COOKIE_REDACTED]" }
          end
        end

        config.default_cassette_options = {
          :record                 => :new_episodes,
          :allow_playback_repeats => true,
          :match_requests_on      => [:method, :uri, :body],
        }
      end
    else
      # Use the original production VCR configuration
      super
    end
  end
end)
