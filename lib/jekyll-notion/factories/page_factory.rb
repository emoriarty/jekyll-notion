# frozen_string_literal: true

module JekyllNotion
  class PageFactory
    def self.for(notion_resource:, site:, plugin:)
      if notion_resource.data_name.nil?
        PageGenerator.new(:notion_resource => notion_resource, :site => site,
                          :plugin => plugin)
      else
        DataGenerator.new(:notion_resource => notion_resource, :site => site, :plugin => plugin)
      end
    end
  end
end
