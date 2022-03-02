# frozen_string_literal: true

module JekyllNotion
  class GeneratorFactory
    def self.for(notion_resource:, site:, plugin:)
      if notion_resource.is_a?(NotionDatabase) && notion_resource.data.nil?
        CollectionGenerator.new(:notion_resource => notion_resource, :site => site, :plugin => plugin)
      else
        DataGenerator.new(:notion_resource => notion_resource, :site => site, :plugin => plugin)
      end
    end
  end
end
