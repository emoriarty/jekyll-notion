# frozen_string_literal: true

module JekyllNotion
  class NotionPage < AbstractNotionResource
    # Returns the nil or a NotionToMd::Page instance
    def fetch
      return nil unless id?

      @fetch ||= NotionToMd::Page.new(:page   => @notion.page(query),
                                      :blocks => @notion.block_children(query))
    end

    def data_name
      config["data"]
    end

    def collection_name
      nil
    end

    private

    def query
      { :id => id }
    end
  end
end
