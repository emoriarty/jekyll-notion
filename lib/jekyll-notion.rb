# frozen_string_literal: true

require "jekyll"
require "notion"
require "notion_to_md"
require "logger"
require "jekyll-notion/generator"
require "vcr"

NotionToMd::Logger.level = Logger::ERROR

Notion.configure do |config|
  config.token = ENV["NOTION_TOKEN"]
end

# Using VCR to record and playback Notion API responses for caching
#
VCR.configure do |config|
  config.cassette_library_dir = File.join(Dir.getwd, ".cache", "jekyll-notion", "vcr_cassettes")
  config.hook_into :faraday # Faraday is used by notion-ruby-client gem
  config.filter_sensitive_data("<NOTION_TOKEN>") { ENV["NOTION_TOKEN"] }
  config.allow_http_connections_when_no_cassette = true
  config.default_cassette_options = {
    :allow_playback_repeats => true,
    :record => :new_episodes
  }
end

module JekyllNotion
  autoload :DatabaseFactory, "jekyll-notion/factories/database_factory"
  autoload :PageFactory, "jekyll-notion/factories/page_factory"
  autoload :AbstractGenerator, "jekyll-notion/generators/abstract_generator"
  autoload :DataGenerator, "jekyll-notion/generators/data_generator"
  autoload :PageGenerator, "jekyll-notion/generators/page_generator"
  autoload :CollectionGenerator, "jekyll-notion/generators/collection_generator"
  autoload :DocumentWithoutAFile, "jekyll-notion/document_without_a_file"
  autoload :PageWithoutAFile, "jekyll-notion/page_without_a_file"
  autoload :AbstractNotionResource, "jekyll-notion/abstract_notion_resource"
  autoload :NotionDatabase, "jekyll-notion/notion_database"
  autoload :NotionPage, "jekyll-notion/notion_page"
  autoload :Cacheable, "jekyll-notion/cacheable"
end

# Cache Notion API responses
Notion::Client.prepend JekyllNotion::Cacheable
