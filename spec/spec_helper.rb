# frozen_string_literal: true

require "jekyll"
require File.expand_path("../lib/jekyll-notion", __dir__)

Jekyll.logger.log_level = :error

RSpec.configure do |config|
  config.run_all_when_everything_filtered = true
  config.filter_run :focus
end
