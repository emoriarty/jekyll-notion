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

    def collection_name
      raise "Do not use the AbstractGenerator class. Implement the collection_name method in a subclass."
    end

    def data_name
      raise "Do not use the AbstractGenerator class. Implement the data_name method in a subclass."
    end
  end
end
