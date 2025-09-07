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
  autoload :DocumentWithoutAFile, "jekyll-notion/document_without_a_file"
  autoload :PageWithoutAFile, "jekyll-notion/page_without_a_file"
  autoload :Cacheable, "jekyll-notion/cacheable"

  module Generators
    autoload :Generator, "jekyll-notion/generators/generator"
    autoload :Collectionable, "jekyll-notion/generators/collectionable"
    autoload :Data, "jekyll-notion/generators/data"
    autoload :Page, "jekyll-notion/generators/page"
    autoload :Collection, "jekyll-notion/generators/collection"
  end
end
