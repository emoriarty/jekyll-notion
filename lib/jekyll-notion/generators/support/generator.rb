module JekyllNotion
  module Generators
    module Support
      class Generator
        class << self
          def call(config:, site:, plugin:, notion_pages:)
            new(config: config, site: site, plugin: plugin, notion_pages: notion_pages).call
          end
        end

        def initialize(config:, site:, plugin:, notion_pages:)
          @notion_pages = notion_pages
          @config = config
          @site = site
          @plugin = plugin
        end

        attr_reader :config, :notion_pages, :site, :plugin
      end
    end
  end
end
