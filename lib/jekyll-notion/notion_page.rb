# frozen_string_literal: true

module JekyllNotion
  class NotionPage < AbstractNotionResource
    # Returns the nil or a NotionToMd::Page instance
    def fetch
      return nil unless id?

      @fetch ||= NotionToMd::Page.new(:page   => @notion.page({ :page_id => id }),
                                      :blocks => build_blocks)
    end

    def data_name
      config["data"]
    end

    def collection_name
      nil
    end
  end
end
