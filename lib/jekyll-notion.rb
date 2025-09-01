# frozen_string_literal: true

require "jekyll"
require "notion"
require "notion_to_md"
require "logger"
require "jekyll-notion/generator"
require "vcr"

NotionToMd::Logger.level = Logger::ERROR

Notion.configure do |config|
  config.token = ENV.fetch("NOTION_TOKEN", nil)
end

module JekyllNotion
  autoload :Generators, "jekyll-notion/generators"
  autoload :DocumentWithoutAFile, "jekyll-notion/document_without_a_file"
  autoload :PageWithoutAFile, "jekyll-notion/page_without_a_file"
  autoload :Cacheable, "jekyll-notion/cacheable"
end
