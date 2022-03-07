# frozen_string_literal: true

module JekyllNotion
  class AbstractGenerator
    def initialize(notion_resource:, site:, plugin:)
      @notion_resource = notion_resource
      @site = site
      @plugin = plugin
    end

    def generate
      raise "Do not use the AbstractGenerator class. Implement the generate method in a subclass."
    end
  end
end
