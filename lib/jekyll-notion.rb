require 'notion'
require 'notion_to_md/logger'
require 'logger'

NotionToMd::Logger.level = Logger::ERROR

Notion.configure do |config|
    config.token = ENV['NOTION_TOKEN']
end