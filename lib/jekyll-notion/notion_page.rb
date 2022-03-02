# frozen_string_literal: true

module JekyllNotion
  class NotionPage
    def initialize(config:)
      @notion = Notion::Client.new
      @config = config
    end

    def page
      return nil unless id?

      @page ||= NotionToMd::Page.new(@notion.page(query))
    end

    def config
      @config || {}
    end

    def id
      config["id"]
    end

    def data
      config["data"]
    end

    private

    def id?
      if id.nil? || id.empty?
        Jekyll.logger.warn("Jekyll Notion:",
                           "page id is not provided. Cannot read from Notion.")
        return false
      end
      true
    end

    def query
      { :id => id }
    end
  end
end
