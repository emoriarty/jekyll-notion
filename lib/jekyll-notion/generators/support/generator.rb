# frozen_string_literal: true

module JekyllNotion
  module Generators
    module Support
      class Generator
        class << self
          def call(config:, site:, notion_pages:)
            new(:config => config, :site => site,
                :notion_pages => notion_pages).call
          end
        end

        def initialize(config:, site:, notion_pages:)
          @notion_pages = notion_pages
          @config = config
          @site = site
        end

        attr_reader :config, :notion_pages, :site
      end
    end
  end
end
