# frozen_string_literal: true

module JekyllNotion
  class NotionPage < AbstractNotionResource
    # Returns the nil or a NotionToMd::Page instance
    def fetch
      return nil unless id?

      @fetch ||= NotionToMd::Page.new(:page => @notion.page(query))
    end

    def data
      puts config
      config["data"]
    end

    private

    def query
      { :id => id }
    end
  end
end
