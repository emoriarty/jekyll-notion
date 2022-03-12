# frozen_string_literal: true

require "jekyll"
require "notion"
require "notion_to_md"
require "logger"
require "jekyll-notion/generator"

NotionToMd::Logger.level = Logger::ERROR

Notion.configure do |config|
  config.token = ENV["NOTION_TOKEN"]
end

module JekyllNotion
  autoload :DatabaseFactory, "jekyll-notion/database_factory"
  autoload :PageFactory, "jekyll-notion/page_factory"
  autoload :AbstractGenerator, "jekyll-notion/abstract_generator"
  autoload :AbstractNotionResource, "jekyll-notion/abstract_notion_resource"
  autoload :CollectionGenerator, "jekyll-notion/collection_generator"
  autoload :DataGenerator, "jekyll-notion/data_generator"
  autoload :PageGenerator, "jekyll-notion/page_generator"
  autoload :DocumentWithoutAFile, "jekyll-notion/document_without_a_file"
  autoload :PageWithoutAFile, "jekyll-notion/page_without_a_file"
  autoload :NotionDatabase, "jekyll-notion/notion_database"
  autoload :NotionPage, "jekyll-notion/notion_page"
end
