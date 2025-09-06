# frozen_string_literal: true

module JekyllNotion
  module Generators
    # Abstract base class for Notion content generators.
    #
    # This class provides a common interface and factory method for creating
    # Jekyll content from Notion pages. Subclasses must implement the {#call}
    # method to define their specific generation behavior.
    #
    # @abstract Subclass and override {#call} to implement content generation logic
    class Generator
      class << self
        # Factory method to create and execute a generator instance.
        #
        # @param config [Hash] Configuration hash for the generator
        # @param site [Jekyll::Site] The Jekyll site instance
        # @param notion_pages [Array<NotionToMd::Page>] Array of Notion pages to process
        # @return [void]
        def call(config:, site:, notion_pages:)
          new(:config => config, :site => site,
              :notion_pages => notion_pages).call
        end
      end

      # Initialize a new generator instance.
      #
      # @param config [Hash] Configuration hash for the generator
      # @param site [Jekyll::Site] The Jekyll site instance
      # @param notion_pages [Array<NotionToMd::Page>] Array of Notion pages to process
      def initialize(config:, site:, notion_pages:)
        @notion_pages = notion_pages
        @config = config
        @site = site
      end

      attr_reader :config, :notion_pages, :site

      # Generate Jekyll content from Notion pages.
      #
      # @abstract Subclasses must implement this method to define their
      #   specific content generation logic.
      # @raise [NotImplementedError] if called on the abstract base class
      # @return [void]
      def call
        raise NotImplementedError, "Subclasses must implement #call"
      end
    end
  end
end
