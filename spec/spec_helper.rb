# frozen_string_literal: true

require "jekyll"
require File.expand_path("../lib/jekyll-notion", __dir__)
require "simplecov"
require "vcr"

SimpleCov.start do
  enable_coverage :branch
end

ENV["JEKYLL_ENV"] = "test"

Jekyll.logger.log_level = :error

VCR.configure do |config|
  config.cassette_library_dir = "spec/fixtures/vcr_cassettes"
  config.hook_into :faraday

  # Redact the Notion token from the VCR cassettes
  config.before_record do |interaction|
    to_be_redacted = interaction.request.headers["Authorization"]

    to_be_redacted.each do |redacted_text|
      interaction.filter!(redacted_text, "<REDACTED>")
    end

    sensitive_values = (ENV["NOTION_SENSITIVE_VALUES"] || "").split("|")
    replacement_values = (ENV["NOTION_SENSITIVE_REPLACEMENTS"] || "").split("|")
    sensitive_values.each_with_index do |sensitive_value, index|
      interaction.filter!(sensitive_value, replacement_values[index])
    end
  end

  config.default_cassette_options = {
    :allow_playback_repeats => true,
    :record                 => :new_episodes,
  }
end

RSpec.configure do |config|
  config.run_all_when_everything_filtered = true
  config.filter_run :focus

  SOURCE_DIR = File.expand_path("fixtures/my_site", __dir__)
  SOURCE_DIR_2 = File.expand_path("fixtures/my_site_2", __dir__)
  DEST_DIR = File.expand_path("dest", __dir__)

  def dest_dir(*files)
    File.join(DEST_DIR, *files)
  end

  # Load support files
  Dir[File.join(__dir__, "support/**/*.rb")].sort.each { |f| require f }
end
